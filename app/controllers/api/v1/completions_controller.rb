require 'ollama-ai'

class API::V1::CompletionsController < API::V1Controller
  include ActionController::Live

  before_action :set_completion, only: %i[ show update destroy ]

  def index
    @completions = Completion.all
    render json: { data: @completions }
  end
  
  def show
    render json: { data: @completion }
  end

  def create
    @completion = Completion.new(completion_params)

    client = Ollama.new(
        credentials: {
          address: 'http://localhost:11434',
        },
        options: {
          server_sent_events: true
        }
      )

    if ActiveModel::Type::Boolean.new.cast(params[:stream])
      response.headers['Content-Type'] = 'application/x-ndjson; charset=utf-8'

      buffered_response = StringIO.new

      begin
        client.generate({
          model: @completion.model,
          prompt: @completion.prompt,
        }) do |event, raw|
          response.stream.write(ndjson({
            model: event['model'],
            created_at: event['created_at'],
            response: event['response'],
            done: event['done'],
          }))
          buffered_response << event['response']
          
          if event['done']
            response.stream.close
          end
        end

        @completion.response = buffered_response.string

        if ActiveModel::Type::Boolean.new.cast(params[:save])
          puts @completion.inspect
          if @completion.save
            # TODO: response?
          else
            # error?
            # TODO response?
          end
        else 
          # TODO noop?
        end

      rescue ActionController::Live::ClientDisconnected
        # TODO: log the error
        # TODO: response?
      end

    else
      data = client.generate({
        model: @completion.model,
        prompt: @completion.prompt,
        stream: false,
      })
      
      @completion.response = data[0]['response']

      if ActiveModel::Type::Boolean.new.cast(params[:save])
        if @completion.save
          head :created, location: @completion      
        else
          render json: { data: { errors: @completion.errors }}, status: :unprocessable_entity
        end
      else 
        render json: { data: @completion }
      end
    end
  ensure
    response.stream.close
  end

  
  def update
    if @completion.update(completion_params)
      head :ok, location: @completion
    else
      render json: { data: { errors: @completion.errors }}, status: :unprocessable_entity
    end
  end

  def destroy
    @completion.destroy!

    head :no_content
  end

  private

    def ndjson(data)
      data.to_json() + "\n"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_completion
      @completion = Completion.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def completion_params
      params.expect(completion: [ :prompt, :model ])
    end
end
