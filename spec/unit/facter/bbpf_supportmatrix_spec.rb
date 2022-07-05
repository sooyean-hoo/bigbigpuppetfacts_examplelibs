# frozen_string_literal: true

## Before running this test...
## Run the following preparation code first at the module root folder
# bbpfcodedir=$PWD/../`basename $PWD ` ; mkdir -p /tmp/media ;  cd  /tmp/media ; rsync -avvphrz $bbpfcodedir ./ ; cd `basename $bbpfcodedir ` ; git reset --hard ; git checkout 4publicversion ;

lib_path = File.join(File.dirname(__FILE__), '../../../lib/')
$LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

lib_path = '/tmp/media/bigbigpuppetfacts/lib/'
$LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

require 'spec_helper'
require 'facter'
require 'facter/bbpf_supportmatrix'

driverspaths = [ File.join(File.dirname(__FILE__), '../../../lib/puppet_x/bigbigfacts/drivers/*.rb') ]
Facter::Util::Bigbigpuppetfacts.drivers(driverspaths)

describe :bbpf_supportmatrix, type: :fact do
  subject(:fact) { Facter.fact(:bbpf_supportmatrix) }

  before :each do
    # perform any action that should be run before every test
    Facter.clear
  end

  it 'returns a value' do
    expect(fact.value).to include({ 'xz_base64' => 'Supported' })
    expect(fact.value).to include({ 'xz' => 'Supported' })
    expect(fact.value).to include({ 'bz2' => 'Supported' })
    expect(fact.value).to include({ 'base64' => 'Supported' })
    expect(fact.value).to include({ 'gz' => 'Supported' })
  end
end
