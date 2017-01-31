require 'typhoeus'
require 'json'
require 'csv'
api_key = 'ADDGOOGLEAPIKEYHERE'
states = Array[ ["AK", "Alaska"],
                ["AL", "Alabama"],
                ["AR", "Arkansas"],
                ["AZ", "Arizona"],
                ["CA", "California"],
                ["CO", "Colorado"],
                ["CT", "Connecticut"],
                ["DC", "District of Columbia"],
                ["DE", "Delaware"],
                ["FL", "Florida"],
                ["GA", "Georgia"],
                #["GU", "Guam"],
                ["HI", "Hawaii"],
                ["IA", "Iowa"],
                ["ID", "Idaho"],
                ["IL", "Illinois"],
                ["IN", "Indiana"],
                ["KS", "Kansas"],
                ["KY", "Kentucky"],
                ["LA", "Louisiana"],
                ["MA", "Massachusetts"],
                ["MD", "Maryland"],
                ["ME", "Maine"],
                ["MI", "Michigan"],
                ["MN", "Minnesota"],
                ["MO", "Missouri"],
                ["MS", "Mississippi"],
                ["MT", "Montana"],
                ["NC", "North Carolina"],
                ["ND", "North Dakota"],
                ["NE", "Nebraska"],
                ["NH", "New Hampshire"],
                ["NJ", "New Jersey"],
                ["NM", "New Mexico"],
                ["NV", "Nevada"],
                ["NY", "New York"],
                ["OH", "Ohio"],
                ["OK", "Oklahoma"],
                ["OR", "Oregon"],
                ["PA", "Pennsylvania"],
                #["PR", "Puerto Rico"],
                ["RI", "Rhode Island"],
                ["SC", "South Carolina"],
                ["SD", "South Dakota"],
                ["TN", "Tennessee"],
                ["TX", "Texas"],
                ["UT", "Utah"],
                ["VA", "Virginia"],
                #["VI", "Virgin Islands"],
                ["VT", "Vermont"],
                ["WA", "Washington"],
                ["WI", "Wisconsin"],
                ["WV", "West Virginia"],
                ["WY", "Wyoming"] ]

csv_header = ["state", "state_name", 'name', "full_address", "address_line1", "address_city", "address_state", "address_zip",'party','phone','url', 'facebook', 'twitter', 'youtube' ]

def find_senators(offices)
  office =  offices.find{|x| x['name'].downcase == 'united states senate'}
  office.nil? ?  [] : office.fetch('officialIndices' , [])
end

def parse_adress(address)
  #puts "parse_address"
  address.is_a? Array
  add = address.first
  #return "full_address", "address_line1", "address_city", "address_state", "address_zip"
  [add.values.join(" "), add.values].flatten
end

def parse_urls(channels)
  #puts "parse_urls"
  facebook = channels.find{|x| x['type'].downcase == 'facebook'} || {}
  twitter = channels.find{|x| x['type'].downcase == 'twitter'} || {}
  youtube = channels.find{|x| x['type'].downcase == 'youtube'} || {}
  [facebook.fetch('id',""), twitter.fetch('id',""), youtube.fetch('id', "")]
end

counter = 0
#col_sep: "\t",
CSV.open("senators.csv", "wb", force_quotes: true) do |csv|
  csv << csv_header
  states.each do |state, state_name|
    puts counter
    puts state_name
    url = "https://www.googleapis.com/civicinfo/v2/representatives?key=#{api_key}&address=#{state_name}"
    response = Typhoeus.get(url, followlocation: true)
    if response.code != 200
      url = "https://www.googleapis.com/civicinfo/v2/representatives?key=#{api_key}&address=#{state}"
      response = Typhoeus.get(url, followlocation: true)
    end
    json_body = JSON.parse(response.body)
    find_senators(json_body['offices']).each do |arr_num|
      s = json_body['officials'][arr_num]
      line = [state, state_name,s.fetch('name'),parse_adress(s.fetch('address')),
              s.fetch('party'), s.fetch('phones', []).first, s.fetch('urls',[]).first, parse_urls(s.fetch('channels')) ].flatten
      #puts line
      csv << line
    end
    #sleep 2
    counter+=1
  end
end



#require "csv"
#parsed_file = CSV.read("addresses.csv")
#CSV.foreach("addresses.csv") do |row|
  #puts "****#{row[1]}****"
#end
