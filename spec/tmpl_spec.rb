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

	it 'loads templates from disk'
	it 'does not require extensions'
	it 'searches template paths and extensions in order'
	it 'gives added templates precedence over disk templates'
	it 'rebuilds replaced templates'
	it 'takes values from an object'
	it 'takes values from a hash'
	it 'supports ${ var }'
	it 'supports {{= var }}'
	it 'supporst {{html}}'
	it 'supports {{if}}'
	it 'supports {{else}}'
	it 'supports {{each}}'
	it 'supports {{tmpl}}'
	it 'supports basic expressions'
	it 'supports method calls'
	it 'substitutes common JavaScript expressions'
	it 'substitutes common JavaScript methods'
end
