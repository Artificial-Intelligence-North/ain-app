require "ollama-ai"

class API::V1::CompletionsController < API::V1Controller
  include ActionController::Live

  before_action :set_completion, only: %i[ show update destroy ]
  before_action :set_client, only: %i[ create ]

  def index
    @completions = Completion.all
    render json: { data: @completions }
  end

  def show
    render json: { data: @completion }
  end

  def create
    @completion = Completion.new(completion_params)
    @completion.user = @current_user

    # set the response to a stream of newline delimited JSON
    if stream_requested?
      response.headers["Content-Type"] = "application/x-ndjson; charset=utf-8"
    end

    buffered_response = StringIO.new

    begin
      # generate a completion using Ollama completion API
      @client.generate({
        model: @completion.model,
        prompt: @completion.prompt,
        stream: stream_requested?,
      }) do |event, raw|
        # write the event to the response stream
        response.stream.write(ndjson({
          model: event["model"],
          created_at: event["created_at"],
          response: event["response"],
          done: event["done"],
        }))
        # buffer the response so we can assemble the response
        buffered_response << event["response"]

        # we can close the stream as soon as the completion is done
        if event["done"]
          response.stream.close
        end
      end
    rescue ActionController::Live::ClientDisconnected
      # noop
    end
    # get the complete response string
    @completion.response = buffered_response&.string

    if save_requested? && @completion.new_record?
      if @completion.save
        render json: { data: @completion }, status: :created
      else
        render json: { data: { errors: @completion.errors } }, status: :unprocessable_entity
      end
    else
      render json: { data: @completion }, status: :ok
    end
  ensure
    response.stream.close
  end

  def update
    if @completion.update(completion_params)
      render json: { data: @completion }, status: :ok
    else
      render json: { data: { errors: @completion.errors } }, status: :unprocessable_entity
    end
  end

  def destroy
    @completion.destroy!

    head :no_content
  end

  protected

  def stream_requested?
    ActiveModel::Type::Boolean.new.cast(params[:stream])
  end

  def save_requested?
    ActiveModel::Type::Boolean.new.cast(params[:save])
  end

  private

  def ndjson(data)
    data.to_json() + "\n"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_completion
    @completion = Completion.find(params.expect(:id))
  end

  def set_client
    @client = Ollama.new(
      credentials: {
        address: "http://localhost:11434",
      },
      options: {
        server_sent_events: true,
      },
    )
  end

  # Only allow a list of trusted parameters through.
  def completion_params
    params.expect(completion: [:prompt, :model])
  end
end
