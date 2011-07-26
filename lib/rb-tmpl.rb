require 'cgi' 

module RbTmpl
	class Tmpl
		attr_reader :template_search_paths
		attr_reader :template_extensions

		def initialize
			@template_search_paths = []
			@template_extensions = []

			@templates = {}
			@compiled_templates = {}
		end

		def add(name, template)
			name = name.to_s
			@templates[name] = template
			@compiled_templates.delete(name)
		end

		def call(name, data = nil)
			name = name.to_s
			code = compiled(name)
			return '' if code.nil?
			data = HashWrapper.new(data) if data.kind_of?(Hash)
			bind = data.instance_eval{ binding } unless data.nil?
			eval(code, bind)
		end

	protected
		class HashWrapper
			def initialize(hash)
				@hash = hash
			end

			def method_missing(method, *arguments, &block)
				@hash[method] || @hash[method.to_s]
			end

			def respond_to(method, include_private)
				super || @hash.key?(method) || @hash.key?(method.to_s)
			end
		end

		def find_file(name)
			@template_search_paths.map do |path|
				file = File.join(path, name)
				ext_files = @template_extensions.map do |ext|
					File.join(path, name + '.' + ext)
				end
				[file] + ext_files
			end.
				flatten.
				find{ |file| File.exist?(file) }
		end

		def find_by_file(name)
			file = find_file(name)
			file.nil? ? nil : File.read(file)
		end

		def find(name)
			return @templates[name] ||= find_by_file(name)
		end	

		def compiled(name)
			@compiled_templates[name] ||= compile(find(name))
		end

		def compile(template)
			puts
			puts template
			template = template.
				gsub(/\\/, '\\\\').
				gsub(/'/, '\\\\\'').
				gsub(/\$\{([^\}]*)\}/, '{{= \1}}')
			code = "__='"
			code << template.gsub(/\{\{[^\}]*\}\}/) do |full_tag|
				tag_contents = full_tag[2...-2].strip
				_, closing_slash, tag, args = tag_contents.match(/^(\/?)([^\s]+)(.*)/).to_a
				if args
					args = args.
						strip.
						gsub('$index', '__i').
						gsub('$value', '__val')
				end
				is_closing = closing_slash == '/'
				tag_code = case
					when is_closing    then 'end'
					when tag == '='    then "__<<CGI.escapeHTML((#{args}).to_s)"
					when tag == 'html' then "__<<(#{args}).to_s"
					when tag == 'if'   then 'if ' + args 
					when tag == 'else' then 'else'
					when tag == 'each' then '(' + args + ').each_with_index do|__val,__i|'
				end
				"';#{tag_code};__<<'"
			end
			code << "';__"
			puts template
			puts code
			puts
			code
		end
	end
end
