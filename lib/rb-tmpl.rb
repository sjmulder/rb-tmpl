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
			puts code
			eval(code, bind)
		end

	protected
		class HashWrapper
			def initialize(hash)
				@hash = hash
			end

			def method_missing(method, *arguments, &block)
				hash[method] || hash[method.to_s]
			end

			def respond_to(method, include_private)
				super || hash.key?(method) || hash.key?(method.to_s)
			end
		end

		def find_file(name)
			@template_search_paths.
				product(@template_extensions).
				map{ |path, extension| File.join(path, name + '.' + extension) }.
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
			str = template.
				gsub(/\\/, '\\\\').
				gsub(/'/, '\\\\\'')
			'\'' + str + '\''
		end
	end
end
