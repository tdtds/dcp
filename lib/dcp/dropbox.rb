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
	end
end
