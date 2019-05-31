require 'java'

class LangScriptRunner < JobRunner

  register_for_job_type('lang_script_job',
                        :create_permissions => :manage_repository,
                        :cancel_permissions => :manage_repository,
                        :run_concurrently => true)

  def run

    begin

      modified_records = []

      job_data = @json.job

      # we need to massage the json sometimes..
      begin
        params = ASUtils.json_parse(@json.job_params[1..-2].delete("\\"))
      rescue JSON::ParserError
        params = {}
      end
      params[:finding_aid_language] = job_data['finding_aid_language']
      params[:finding_aid_script] = job_data['finding_aid_script']
      params[:all_repos] = job_data['all_repos']

      log(Time.now)

      DB.open do |db|

        # languages
        unless params[:finding_aid_language].nil?
          lang_enum = db[:enumeration].filter(:name => 'language_iso639_2').select(:id)
          und_lang = db[:enumeration_value].filter(:value => 'und', :enumeration_id => lang_enum ).select(:id)
          new_lang = db[:enumeration_value].filter(:value => params[:finding_aid_language], :enumeration_id => lang_enum ).select(:id)
          existing_resources_lang = params[:all_repos] == true ? db[:resource].where(finding_aid_language_id: und_lang).all : db[:resource].where(finding_aid_language_id: und_lang, repo_id: @job.repo_id).all
          existing_resources_lang.each do |existing_resource_lang|
            db[:resource].filter(:id => existing_resource_lang[:id]).update(:finding_aid_language_id => new_lang)
            uri = "/repositories/#{existing_resource_lang[:repo_id]}/resources/#{existing_resource_lang[:id]}"
            modified_records << uri
          end
        end

        # scripts
        unless params[:finding_aid_script].nil?
          script_enum = db[:enumeration].filter(:name => 'script_iso15924').select(:id)
          und_script = db[:enumeration_value].filter(:value => 'Zyyy', :enumeration_id => script_enum ).select(:id)
          new_script = db[:enumeration_value].filter(:value => params[:finding_aid_script], :enumeration_id => script_enum ).select(:id)
          existing_resources_script = params[:all_repos] == true ? db[:resource].where(finding_aid_script_id: und_script).all : db[:resource].where(finding_aid_script_id: und_script, repo_id: @job.repo_id).all
          existing_resources_script.each do |existing_resource_script|
            db[:resource].filter(:id => existing_resource_script[:id]).update(:finding_aid_script_id => new_script)
            uri = "/repositories/#{existing_resource_script[:repo_id]}/resources/#{existing_resource_script[:id]}"
            modified_records << uri
          end
        end

      end

      if modified_records.empty?
        @job.write_output("All done, no records modified.")
      else
        @job.write_output("#{modified_records.uniq.count} records modified.")
        @job.write_output("All done, logging modified records.")
      end

    self.success!

    log("===")

    @job.record_created_uris(modified_records.uniq)

    rescue Exception => e
      @job.write_output(e.message)
      @job.write_output(e.backtrace)
      raise e

    ensure
      @job.write_output("Done.")
    end

  end

  def log(s)
    Log.debug(s)
    @job.write_output(s)
  end

end
