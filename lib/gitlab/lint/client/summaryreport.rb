

module Gitlab
    module Lint
      module Client
        
        class SummaryReport

          def initialize(status, errors)
            @status = status
            @errors = errors
          end

          def summary()
            case @status
                when "valid"
                    success()
                when "invalid"
                    failure()
                else 
                    abort("A problem was encountered parsing status : " + @status)  
            end
          end

          private
          
          def failure()
            abort("Gitlab yaml file is invalid with errors:\n\n" + @errors.join("\n"))
          end

          def success()
            puts "GitLab yaml file passed linting"
            exit(0)
          end
        end
      end
    end
  end
  

