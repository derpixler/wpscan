require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CacheFileStore do

  before :all do
    @cache_dir = SPEC_CACHE_DIR + '/cache_file_store'
  end

  before :each do
    Dir.delete(@cache_dir) rescue nil

    @cache = CacheFileStore.new(@cache_dir)
  end

  after :each do
    @cache.clean
  end

  describe "#storage_path" do
    it "returns the storage path given in the #new" do
      @cache.storage_path.should == @cache_dir
    end
  end

  describe "#serializer" do
    it "should return the default serializer : YAML" do
      @cache.serializer.should == YAML
      @cache.serializer.should_not == Marshal
    end
  end

  describe "#clean" do
    it "should remove all files from the cache dir (#{@cache_dir}" do
      # let's create some files into the directory first
      (0..5).each do |i|
        File.new(@cache_dir + "/file_#{i}.txt", File::CREAT)
      end

      count_files_in_dir(@cache_dir, 'file_*.txt').should == 6
      @cache.clean
      count_files_in_dir(@cache_dir).should == 0
    end
  end

  describe "#read_entry (nonexistent entry)" do
    it "should return nil" do
      @cache.read_entry(Digest::SHA1.hexdigest('hello world')).should be_nil
    end
  end

  describe "#write_entry, #read_entry (string)" do
    it "should get the same entry" do
      cache_timeout = 10
      @cache.write_entry('some_key', 'Hello World !', cache_timeout)
      @cache.read_entry('some_key').should == 'Hello World !'
    end
  end

  ## TODO write / read for an object

  describe "#write_entry with cache_timeout = 0" do
    it "the entry should not be written" do
      cache_timeout = 0
      @cache.write_entry('another_key', 'Another Hello World !', cache_timeout)
      @cache.read_entry('another_key').should be_nil
    end
  end
end