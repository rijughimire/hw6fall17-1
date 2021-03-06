require 'rails_helper'

describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('When Harry Met Sally')
        Movie.find_in_tmdb('When Harry Met Sally')
      end
      it 'should return empty array if the search term is not found in Tmdb' do
        expect(Tmdb::Movie).to receive(:find).with('blah').and_return(nil)
        result = Movie.find_in_tmdb('blah')
        expect(result).to eq([])
      end
      it 'should parse the information successfully' do 
        movieArray = [double("movie1")]
          releases = [{"countries" => [{"certification" => "", "iso_3166_1" => "US"}]}]
          allow(movieArray[0]).to receive(:id).and_return('1')
          allow(movieArray[0]).to receive(:title).and_return('first_title')
          allow(movieArray[0]).to receive(:release_date).and_return('date1')
          allow(Tmdb::Movie).to receive(:find).with('When Harry Met Sally').and_return(movieArray)
          allow(Tmdb::Movie).to receive(:releases).with('1').and_return(releases[0])
          # allow(Tmdb::Movie).to receive(:releases).with('2').and_return(releases[1])
          results = Movie.find_in_tmdb('When Harry Met Sally')
          expect(results[0][:tmdb_id]).to eq('1')
          # expect(results[1][:tmdb_id]).to eq('2')
          expect(results[0][:title]).to eq('first_title')
          # expect(results[1][:title]).to eq('second_title')
          expect(results[0][:rating]).to eq('Not rated')
          # expect(results[1][:rating]).to eq('PG')
          expect(results[0][:release_date]).to eq('date1')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if the key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('When Harry Met Sally') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  describe 'Add movie from TMDb' do
    context 'with valid key' do
       before :each do
        expect(Tmdb::Movie).to receive(:detail).with(1).and_return(
          { 'overview' => "Some Description", "release_date" => "1989-07-21", "title" => "When Harry Met Sally" }  
        )
      end
      it 'should parse information successfully' do
        expect(Movie).to receive(:get_rating).with(1).and_return('R')
        result = Movie.create_from_tmdb(1)
        expect(result[:rating]).to eq("R")
        expect(result[:title]).to eq("When Harry Met Sally")
        expect(result[:description]).to eq("Some Description")
        expect(result[:release_date]).to eq("1989-07-21")
      end
    end
    context 'with invalid key' do 
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('When Harry Met Sally')}.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  describe 'get rating' do
    it 'should return a rating' do
      expect(Tmdb::Movie).to receive(:releases).with(1).and_return({'iso_3166_1' => 'US'})
      Movie.get_rating(1)
    end
  end
end
