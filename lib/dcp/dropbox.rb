#
# wrapper of DropboxApi
#
module DCP
	class Dropbox
		def initialize(token)
			@client = DropboxApi::Client.new(token)
		end

		def open(path, opts)
			if opts =~ /w/ # write
				client = @client
				info = DropboxApi::Metadata::CommitInfo.new('path'=>path, 'mode'=>:add)
				cursor = client.upload_session_start('')
				cursor.define_singleton_method(:write) do |data|
					client.upload_session_append_v2(cursor, data)
				end
				yield cursor
				client.upload_session_finish(cursor, info)
			else # read (default)
				raise StandardError.new('read from dropbox does not implement.')
			end
		end

		def file?(path)
			return false if path.empty? || path == '/'
			begin
				@client.get_metadata(path).class == DropboxApi::Metadata::File
			rescue ::DropboxApi::Errors::NotFoundError
				raise Errno::ENOENT.new('file not found on dropbox')
			end
		end

		def directory?(path)
			return true if path.empty? || path == '/'
			begin
				@client.get_metadata(path).class == DropboxApi::Metadata::Folder
			rescue ::DropboxApi::Errors::NotFoundError
				raise Errno::ENOENT.new('file not found on dropbox')
			end
		end
	end
end
