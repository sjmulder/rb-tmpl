require 'spec/spec_helper.rb'

describe Tmpl do
	it 'loads templates from the add method' do
		tmpl = Tmpl.new
		tmpl.add(:test, 'Foo')
		tmpl.call(:test) == 'Foo'
	end

	it 'accepts strings and symbols' do
		tmpl = Tmpl.new
		tmpl.add(:foo, 'Foo')
		tmpl.add('bar', 'Bar')
		tmpl.call(:foo).should == 'Foo'
		tmpl.call(:bar).should == 'Bar'
		tmpl.call('foo').should  == 'Foo'
		tmpl.call('bar').should  == 'Bar'
	end

	it 'escapes single quotes' do
		tmpl = Tmpl.new
		tmpl.add(:test, '\'Hello!\'')
		tmpl.call(:test).should == '\'Hello!\''
	end

	it 'escapes escape sequences' do
		tmpl = Tmpl.new
		tmpl.add(:test, 'Dear mum,\n')
		tmpl.call(:test).should == 'Dear mum,\n'
	end

	it 'loads templates from disk' do
		tmpl = Tmpl.new
		tmpl.template_search_paths << 'templates'
		tmpl.template_search_paths << 'templates/sub/'
		FileUtils.mkdir('templates')
		FileUtils.mkdir('templates/sub')
		File.open('templates/foo', 'w'){ |f| f.write('Foo') }
		File.open('templates/sub/bar', 'w'){ |f| f.write('Bar') }
		tmpl.call(:foo).should == 'Foo'
		tmpl.call(:bar).should == 'Bar'
	end

	it 'supports extensions for template files' do
		tmpl = Tmpl.new
		tmpl.template_search_paths << '.'
		tmpl.template_extensions << 'tmpl'
		File.open('foo.tmpl', 'w'){ |f| f.write('Foo') }
		tmpl.call(:foo).should == 'Foo'
	end

	it 'gives added templates precedence over disk templates' do
		tmpl = Tmpl.new
		tmpl.add(:foo, 'Memory')
		tmpl.template_search_paths << '.'
		File.open('foo', 'w'){ |f| f.write('Disk') }
		tmpl.call(:foo).should == 'Memory'
	end
	
	it 'gives files without extensions precence over those with' do
		tmpl = Tmpl.new
		tmpl.template_search_paths << '.'
		tmpl.template_extensions << 'tmpl'
		File.open('foo', 'w'){ |f| f.write('Without') }
		File.open('foo.tmpl', 'w'){ |f| f.write('With') }
		tmpl.call(:foo).should == 'Without'
	end

	it 'searches template paths and extensions in order' do
		tmpl = Tmpl.new
		tmpl.template_search_paths << 'dir1' << 'dir2'
		tmpl.template_extensions << 'ext1' << 'ext2'
		FileUtils.mkdir('dir1')
		FileUtils.mkdir('dir2')
		File.open('dir1/foo.ext1', 'w'){ |f| f.write('1') }
		File.open('dir1/foo.ext2', 'w'){ |f| f.write('2') }
		File.open('dir2/foo', 'w'){ |f| f.write('3') }
		File.open('dir2/foo.ext1', 'w'){ |f| f.write('4') }
		tmpl.call(:foo).should == '1'
	end

	it 'supports {{=}} with data from an object' do
		class BarData
			def bar; 'Bar'; end
		end
		tmpl = Tmpl.new
		tmpl.add(:foo, '{{= bar}}')
		tmpl.call(:foo, BarData.new).should == 'Bar'
	end

	it 'supports {{=}} with data from a hash' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '{{= bar}}')
		tmpl.call(:foo, { :bar => 'Bar' }).should == 'Bar'
	end

	it 'escapes HTML in {{=}}' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '{{= evil}}')
		tmpl.call(:foo, { :evil => '<script>' }).should == '&lt;script&gt;'
	end

	it 'supports ${} shorthand' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '${bar}')
		tmpl.call(:foo, { :bar => 'Bar' }).should == 'Bar'
	end

	it 'supports {{html}}' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '{{html code}}')
		tmpl.call(:foo, { :code => '<script>' }).should == '<script>'
	end

	it 'supports {{if}}' do
		template =
			'{{if t}}t{{/if}}' +
			'{{if f}}f{{/if}}'
		tmpl = Tmpl.new
		tmpl.add(:foo, template)
		tmpl.call(:foo, { :t => true, :f => false }).should == 't'
	end

	it 'supports {{else}}' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '{{if f}}t{{else}}f{{/if}}')
		tmpl.call(:foo, { :f => false }).should == 'f'
	end

	it 'supports {{each}}' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '{{each list}}${$index}${$value}{{/each}}')
		data = { :list => [ 'a', 'b' ] }
		tmpl.call(:foo, data).should == '0a1b'
	end

	it 'supports {{each(i,x)}}' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '{{each(i,x) list}}${i}${x}{{/each}}')
		data = { :list => [ 'a', 'b' ] }
		tmpl.call(:foo, data).should == '0a1b'
	end

	it 'supports {{tmpl}}' do
		tmpl = Tmp.new
		tmpl.add(:foo, '{{tmpl bar}}')
		tmpl.add(:bar, '?{x}')
		tmpl.call(:foo, {:x => 'Yay'}).should == 'Yay'
	end

	it 'supports {{tmpl(data)}}' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '${var},{{tmpl(sub) bar}}')
		tmpl.add(:bar, '${var}')
		data = {:var => 'outer', :sub => {:var => 'inner'}}
		tmpl.call(:foo, data).should == 'outer,inner'
	end

	it 'supports basic expressions' do
		tmpl = Tmpl.new
		tmpl.add(:eq_t, '{{if 1 == 1}}y{{/if}}')
		tmpl.add(:eq_f, '{{if 1 == 2}}n{{/if}}')
		tmpl.add(:lt_f, '{{if 1 < 1}}n{{/if}}')
		tmpl.add(:lt_t, '{{if 1 < 2}}y{{/if}}')
		tmpl.add(:eq_var_t, '{{if var == 1}}y{{/if}}')
		tmpl.add(:eq_var_f, '{{if var == 2}}n{{/if}}')
		tmpl.call(:eq_t).should == 'y'
		tmpl.call(:eq_f).should == ''
		tmpl.call(:lt_f).should == ''
		tmpl.call(:lt_t).should == 'y'
		tmpl.call(:eq_var_t, {:var => 1}).should == 'y'
		tmpl.call(:eq_var_f, {:var => 1}).should == 'n'
	end

	it 'supports method calls' do
		tmpl = Tmpl.new
		tmpl.add(:foo, '?{list.length}')
		tmpl.call(:foo, {:list => [1, 2]}).call == '2'
	end

	it 'substitutes common JavaScript expressions'
	it 'substitutes common JavaScript methods'
end
