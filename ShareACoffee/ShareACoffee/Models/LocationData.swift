import Foundation

struct LocationData {
    // List of countries
    static let countries = [
        "United States",
        "Canada",
        "United Kingdom",
        "Australia",
        "Germany",
        "France",
        "Spain",
        "Italy",
        "Netherlands",
        "Belgium",
        "Switzerland",
        "Austria",
        "Sweden",
        "Norway",
        "Denmark",
        "Finland",
        "Ireland",
        "Portugal",
        "Greece",
        "Poland",
        "Czech Republic",
        "Japan",
        "South Korea",
        "Singapore",
        "New Zealand",
        "Mexico",
        "Brazil",
        "Argentina",
        "Chile",
        "India",
        "China"
    ].sorted()
    
    static let statesAndCities: [String: [String]] = [
        "Alabama": ["Birmingham", "Montgomery", "Mobile", "Huntsville", "Tuscaloosa"],
        "Alaska": ["Anchorage", "Fairbanks", "Juneau", "Sitka", "Ketchikan"],
        "Arizona": ["Phoenix", "Tucson", "Mesa", "Chandler", "Scottsdale", "Glendale", "Tempe"],
        "Arkansas": ["Little Rock", "Fort Smith", "Fayetteville", "Springdale", "Jonesboro"],
        "California": ["Los Angeles", "San Diego", "San Jose", "San Francisco", "Fresno", "Sacramento", "Long Beach", "Oakland", "Bakersfield", "Anaheim", "Santa Ana", "Riverside", "Stockton", "Irvine"],
        "Colorado": ["Denver", "Colorado Springs", "Aurora", "Fort Collins", "Lakewood", "Thornton", "Arvada", "Boulder"],
        "Connecticut": ["Bridgeport", "New Haven", "Stamford", "Hartford", "Waterbury"],
        "Delaware": ["Wilmington", "Dover", "Newark", "Middletown", "Smyrna"],
        "Florida": ["Jacksonville", "Miami", "Tampa", "Orlando", "St. Petersburg", "Hialeah", "Tallahassee", "Fort Lauderdale", "Port St. Lucie", "Cape Coral", "Pembroke Pines", "Hollywood"],
        "Georgia": ["Atlanta", "Augusta", "Columbus", "Macon", "Savannah", "Athens", "Sandy Springs"],
        "Hawaii": ["Honolulu", "Pearl City", "Hilo", "Kailua", "Waipahu"],
        "Idaho": ["Boise", "Meridian", "Nampa", "Idaho Falls", "Pocatello", "Caldwell", "Coeur d'Alene", "Twin Falls"],
        "Illinois": ["Chicago", "Aurora", "Rockford", "Joliet", "Naperville", "Springfield", "Peoria", "Elgin"],
        "Indiana": ["Indianapolis", "Fort Wayne", "Evansville", "South Bend", "Carmel", "Bloomington"],
        "Iowa": ["Des Moines", "Cedar Rapids", "Davenport", "Sioux City", "Iowa City"],
        "Kansas": ["Wichita", "Overland Park", "Kansas City", "Olathe", "Topeka", "Lawrence"],
        "Kentucky": ["Louisville", "Lexington", "Bowling Green", "Owensboro", "Covington"],
        "Louisiana": ["New Orleans", "Baton Rouge", "Shreveport", "Lafayette", "Lake Charles"],
        "Maine": ["Portland", "Lewiston", "Bangor", "South Portland", "Auburn"],
        "Maryland": ["Baltimore", "Frederick", "Rockville", "Gaithersburg", "Bowie", "Annapolis"],
        "Massachusetts": ["Boston", "Worcester", "Springfield", "Cambridge", "Lowell", "Brockton", "Quincy"],
        "Michigan": ["Detroit", "Grand Rapids", "Warren", "Sterling Heights", "Ann Arbor", "Lansing"],
        "Minnesota": ["Minneapolis", "St. Paul", "Rochester", "Duluth", "Bloomington"],
        "Mississippi": ["Jackson", "Gulfport", "Southaven", "Hattiesburg", "Biloxi"],
        "Missouri": ["Kansas City", "St. Louis", "Springfield", "Columbia", "Independence"],
        "Montana": ["Billings", "Missoula", "Great Falls", "Bozeman", "Helena"],
        "Nebraska": ["Omaha", "Lincoln", "Bellevue", "Grand Island", "Kearney"],
        "Nevada": ["Las Vegas", "Henderson", "Reno", "North Las Vegas", "Sparks"],
        "New Hampshire": ["Manchester", "Nashua", "Concord", "Derry", "Dover"],
        "New Jersey": ["Newark", "Jersey City", "Paterson", "Elizabeth", "Edison", "Woodbridge"],
        "New Mexico": ["Albuquerque", "Las Cruces", "Rio Rancho", "Santa Fe", "Roswell"],
        "New York": ["New York City", "Buffalo", "Rochester", "Yonkers", "Syracuse", "Albany", "New Rochelle"],
        "North Carolina": ["Charlotte", "Raleigh", "Greensboro", "Durham", "Winston-Salem", "Fayetteville", "Cary"],
        "North Dakota": ["Fargo", "Bismarck", "Grand Forks", "Minot", "West Fargo"],
        "Ohio": ["Columbus", "Cleveland", "Cincinnati", "Toledo", "Akron", "Dayton"],
        "Oklahoma": ["Oklahoma City", "Tulsa", "Norman", "Broken Arrow", "Edmond"],
        "Oregon": ["Portland", "Salem", "Eugene", "Gresham", "Hillsboro", "Beaverton"],
        "Pennsylvania": ["Philadelphia", "Pittsburgh", "Allentown", "Erie", "Reading", "Scranton"],
        "Rhode Island": ["Providence", "Warwick", "Cranston", "Pawtucket", "East Providence"],
        "South Carolina": ["Charleston", "Columbia", "North Charleston", "Mount Pleasant", "Rock Hill"],
        "South Dakota": ["Sioux Falls", "Rapid City", "Aberdeen", "Brookings", "Watertown"],
        "Tennessee": ["Nashville", "Memphis", "Knoxville", "Chattanooga", "Clarksville", "Murfreesboro"],
        "Texas": ["Houston", "San Antonio", "Dallas", "Austin", "Fort Worth", "El Paso", "Arlington", "Corpus Christi", "Plano", "Laredo", "Lubbock", "Irving"],
        "Utah": ["Salt Lake City", "West Valley City", "Provo", "West Jordan", "Orem", "Sandy"],
        "Vermont": ["Burlington", "South Burlington", "Rutland", "Barre", "Montpelier"],
        "Virginia": ["Virginia Beach", "Norfolk", "Chesapeake", "Richmond", "Newport News", "Alexandria", "Hampton"],
        "Washington": ["Seattle", "Spokane", "Tacoma", "Vancouver", "Bellevue", "Kent", "Everett"],
        "West Virginia": ["Charleston", "Huntington", "Morgantown", "Parkersburg", "Wheeling"],
        "Wisconsin": ["Milwaukee", "Madison", "Green Bay", "Kenosha", "Racine"],
        "Wyoming": ["Cheyenne", "Casper", "Laramie", "Gillette", "Rock Springs"]
    ]
    
    // Canada provinces and cities
    static let canadianProvincesAndCities: [String: [String]] = [
        "Alberta": ["Calgary", "Edmonton", "Red Deer", "Lethbridge", "Medicine Hat"],
        "British Columbia": ["Vancouver", "Victoria", "Surrey", "Burnaby", "Richmond", "Kelowna"],
        "Manitoba": ["Winnipeg", "Brandon", "Steinbach", "Thompson", "Portage la Prairie"],
        "New Brunswick": ["Moncton", "Saint John", "Fredericton", "Dieppe", "Miramichi"],
        "Newfoundland and Labrador": ["St. John's", "Mount Pearl", "Corner Brook", "Conception Bay South"],
        "Nova Scotia": ["Halifax", "Sydney", "Dartmouth", "Truro", "New Glasgow"],
        "Ontario": ["Toronto", "Ottawa", "Mississauga", "Brampton", "Hamilton", "London", "Markham", "Vaughan", "Kitchener", "Windsor"],
        "Prince Edward Island": ["Charlottetown", "Summerside", "Stratford", "Cornwall"],
        "Quebec": ["Montreal", "Quebec City", "Laval", "Gatineau", "Longueuil", "Sherbrooke", "Saguenay"],
        "Saskatchewan": ["Saskatoon", "Regina", "Prince Albert", "Moose Jaw", "Swift Current"]
    ]
    
    // UK regions and cities
    static let ukRegionsAndCities: [String: [String]] = [
        "England": ["London", "Manchester", "Birmingham", "Leeds", "Liverpool", "Newcastle", "Sheffield", "Bristol", "Leicester", "Nottingham", "Southampton", "Brighton"],
        "Scotland": ["Edinburgh", "Glasgow", "Aberdeen", "Dundee", "Inverness", "Stirling"],
        "Wales": ["Cardiff", "Swansea", "Newport", "Wrexham", "Barry"],
        "Northern Ireland": ["Belfast", "Derry", "Lisburn", "Newry", "Armagh"]
    ]
    
    // Australia states and cities
    static let australianStatesAndCities: [String: [String]] = [
        "New South Wales": ["Sydney", "Newcastle", "Wollongong", "Canberra", "Central Coast"],
        "Victoria": ["Melbourne", "Geelong", "Ballarat", "Bendigo", "Shepparton"],
        "Queensland": ["Brisbane", "Gold Coast", "Sunshine Coast", "Townsville", "Cairns", "Toowoomba"],
        "South Australia": ["Adelaide", "Mount Gambier", "Whyalla", "Murray Bridge"],
        "Western Australia": ["Perth", "Bunbury", "Geraldton", "Albany", "Kalgoorlie"],
        "Tasmania": ["Hobart", "Launceston", "Devonport", "Burnie"],
        "Northern Territory": ["Darwin", "Alice Springs", "Palmerston"],
        "Australian Capital Territory": ["Canberra"]
    ]
    
    // Major cities for countries without state/province structure
    static let majorCitiesByCountry: [String: [String]] = [
        "Germany": ["Berlin", "Munich", "Hamburg", "Frankfurt", "Cologne", "Stuttgart", "Düsseldorf", "Dortmund", "Essen", "Leipzig", "Bremen", "Dresden", "Hanover", "Nuremberg", "Duisburg", "Bochum", "Wuppertal", "Bielefeld", "Bonn", "Münster"],
        "France": ["Paris", "Marseille", "Lyon", "Toulouse", "Nice", "Nantes", "Strasbourg", "Montpellier", "Bordeaux", "Lille", "Rennes", "Reims", "Le Havre", "Saint-Étienne", "Toulon", "Grenoble", "Dijon", "Angers", "Nîmes", "Villeurbanne"],
        "Spain": ["Madrid", "Barcelona", "Valencia", "Seville", "Zaragoza", "Málaga", "Murcia", "Palma", "Las Palmas", "Bilbao", "Alicante", "Córdoba", "Valladolid", "Vigo", "Gijón", "L'Hospitalet", "Granada", "Vitoria-Gasteiz", "Elche", "Oviedo"],
        "Italy": ["Rome", "Milan", "Naples", "Turin", "Palermo", "Genoa", "Bologna", "Florence", "Bari", "Venice", "Verona", "Catania", "Padua", "Trieste", "Brescia", "Taranto", "Prato", "Parma", "Modena", "Reggio Calabria"],
        "Netherlands": ["Amsterdam", "Rotterdam", "The Hague", "Utrecht", "Eindhoven", "Tilburg", "Groningen", "Almere", "Breda", "Nijmegen", "Enschede", "Haarlem", "Arnhem", "Zaanstad", "Amersfoort", "'s-Hertogenbosch", "Apeldoorn", "Hoofddorp", "Maastricht", "Leiden"],
        "Belgium": ["Brussels – Capital Region", "Antwerp", "Ghent", "Charleroi", "Liège", "Bruges", "Namur", "Leuven", "Mons", "Mechelen", "Aalst", "La Louvière", "Kortrijk", "Hasselt", "Ostend", "Sint-Niklaas", "Tournai", "Genk", "Seraing", "Roeselare"],
        "Switzerland": ["Zurich", "Geneva", "Basel – City-Canton", "Lausanne", "Bern", "Winterthur", "Lucerne", "St. Gallen", "Lugano", "Biel/Bienne", "Thun", "Köniz", "La Chaux-de-Fonds", "Fribourg", "Schaffhausen", "Chur", "Vernier", "Neuchâtel", "Uster", "Sion"],
        "Austria": ["Vienna – Federal State", "Graz", "Linz", "Salzburg", "Innsbruck", "Klagenfurt", "Villach", "Wels", "Sankt Pölten", "Dornbirn", "Wiener Neustadt", "Steyr", "Feldkirch", "Bregenz", "Leonding", "Klosterneuburg", "Baden", "Wolfsberg", "Leoben", "Krems"],
        "Sweden": ["Stockholm", "Gothenburg", "Malmö", "Uppsala", "Västerås", "Örebro", "Linköping", "Helsingborg", "Jönköping", "Norrköping", "Lund", "Umeå", "Gävle", "Borås", "Södertälje", "Eskilstuna", "Karlstad", "Täby", "Växjö", "Halmstad"],
        "Norway": ["Oslo", "Bergen", "Trondheim", "Stavanger", "Drammen", "Fredrikstad", "Kristiansand", "Sandnes", "Tromsø", "Sarpsborg", "Skien", "Ålesund", "Sandefjord", "Haugesund", "Tønsberg", "Moss", "Porsgrunn", "Bodø", "Arendal", "Hamar"],
        "Denmark": ["Copenhagen", "Aarhus", "Odense", "Aalborg", "Esbjerg", "Randers", "Kolding", "Horsens", "Vejle", "Roskilde", "Herning", "Hørsholm", "Helsingør", "Silkeborg", "Næstved", "Fredericia", "Viborg", "Køge", "Holstebro", "Taastrup"],
        "Finland": ["Helsinki", "Espoo", "Tampere", "Vantaa", "Oulu", "Turku", "Jyväskylä", "Lahti", "Kuopio", "Pori", "Joensuu", "Lappeenranta", "Hämeenlinna", "Vaasa", "Seinäjoki", "Rovaniemi", "Mikkeli", "Kotka", "Salo", "Porvoo"],
        "Ireland": ["Dublin", "Cork", "Limerick", "Galway", "Waterford", "Drogheda", "Dundalk", "Swords", "Bray", "Navan", "Ennis", "Kilkenny", "Carlow", "Tralee", "Newbridge", "Naas", "Athlone", "Portlaoise", "Mullingar", "Wexford"],
        "Portugal": ["Lisbon", "Porto", "Vila Nova de Gaia", "Amadora", "Braga", "Coimbra", "Funchal", "Setúbal", "Almada", "Agualva-Cacém", "Queluz", "Rio Tinto", "Corroios", "Barreiro", "Évora", "Matosinhos", "Gondomar", "Guimarães", "Odivelas", "Faro"],
        "Greece": ["Athens", "Thessaloniki", "Patras", "Heraklion", "Larissa", "Volos", "Rhodes", "Ioannina", "Chania", "Chalcis", "Agrinio", "Katerini", "Kalamata", "Kavala", "Lamia", "Serres", "Trikala", "Alexandroupoli", "Xanthi", "Kozani"],
        "Poland": ["Warsaw", "Kraków", "Łódź", "Wrocław", "Poznań", "Gdańsk", "Szczecin", "Bydgoszcz", "Lublin", "Białystok", "Katowice", "Gdynia", "Częstochowa", "Radom", "Sosnowiec", "Toruń", "Kielce", "Gliwice", "Zabrze", "Bytom"],
        "Czech Republic": ["Prague", "Brno", "Ostrava", "Plzeň", "Liberec", "Olomouc", "České Budějovice", "Hradec Králové", "Ústí nad Labem", "Pardubice", "Zlín", "Havířov", "Kladno", "Most", "Opava", "Frýdek-Místek", "Jihlava", "Teplice", "Karviná", "Děčín"],
        "Japan": ["Tokyo", "Osaka", "Yokohama", "Nagoya", "Sapporo", "Fukuoka", "Kobe", "Kyoto", "Kawasaki", "Hiroshima", "Sendai", "Chiba", "Kitakyushu", "Sakai", "Niigata", "Hamamatsu", "Kumamoto", "Sagamihara", "Shizuoka", "Okayama", "Okinawa", "Naha"],
        "South Korea": ["Seoul", "Busan", "Incheon", "Daegu", "Daejeon", "Gwangju", "Suwon", "Ulsan", "Changwon", "Goyang", "Yongin", "Seongnam", "Cheongju", "Bucheon", "Ansan", "Jeonju", "Cheonan", "Pohang", "Gimhae", "Uijeongbu"],
        "Singapore": ["Singapore"],
        "New Zealand": ["Auckland", "Wellington", "Christchurch", "Hamilton", "Tauranga", "Dunedin", "Palmerston North", "Napier", "Porirua", "Hibiscus Coast", "New Plymouth", "Rotorua", "Whangarei", "Nelson", "Hastings", "Invercargill", "Upper Hutt", "Gisborne", "Blenheim", "Pukekohe"],
        "Mexico": ["Mexico City", "Guadalajara", "Monterrey", "Puebla", "Tijuana", "León", "Juárez", "Cancún", "Zapopan", "Mérida", "San Luis Potosí", "Aguascalientes", "Hermosillo", "Saltillo", "Mexicali", "Culiacán", "Querétaro", "Chihuahua", "Morelia", "Reynosa"],
        "Brazil": ["São Paulo", "Rio de Janeiro", "Brasília – Federal District", "Salvador", "Fortaleza", "Belo Horizonte", "Manaus", "Curitiba", "Recife", "Porto Alegre", "Belém", "Goiânia", "Guarulhos", "Campinas", "São Luís", "São Gonçalo", "Maceió", "Duque de Caxias", "Natal", "Teresina"],
        "Argentina": ["Buenos Aires – Federal District", "Córdoba", "Rosario", "Mendoza", "La Plata", "San Miguel de Tucumán", "Mar del Plata", "Salta", "Santa Fe", "San Juan", "Resistencia", "Santiago del Estero", "Corrientes", "Bahía Blanca", "Posadas", "Paraná", "Neuquén", "Formosa", "San Salvador de Jujuy", "La Rioja"],
        "Chile": ["Santiago", "Valparaíso", "Concepción", "La Serena", "Antofagasta", "Temuco", "Rancagua", "Talca", "Arica", "Chillán", "Iquique", "Puerto Montt", "Los Ángeles", "Coquimbo", "Osorno", "Valdivia", "Punta Arenas", "Quillota", "Quilpué", "Copiapó"],
        "India": ["Mumbai", "Delhi", "Bangalore", "Hyderabad", "Chennai", "Kolkata", "Pune", "Ahmedabad", "Jaipur", "Surat", "Lucknow", "Kanpur", "Nagpur", "Indore", "Thane", "Bhopal", "Visakhapatnam", "Patna", "Vadodara", "Ghaziabad"],
        "China": ["Hong Kong – Special Administrative Region", "Macau – Special Administrative Region", "Beijing", "Shanghai", "Guangzhou", "Shenzhen", "Chengdu", "Chongqing", "Tianjin", "Wuhan", "Hangzhou", "Xi'an", "Suzhou", "Zhengzhou", "Nanjing", "Shenyang", "Dongguan", "Changsha", "Harbin", "Qingdao"]
    ]
    
    static let states = statesAndCities.keys.sorted()
    
    static func cities(for state: String) -> [String] {
        return statesAndCities[state]?.sorted() ?? []
    }
    
    // Get states/provinces for a country
    static func statesOrProvinces(for country: String) -> [String] {
        switch country {
        case "United States":
            return states
        case "Canada":
            return canadianProvincesAndCities.keys.sorted()
        case "United Kingdom":
            return ukRegionsAndCities.keys.sorted()
        case "Australia":
            return australianStatesAndCities.keys.sorted()
        default:
            return [] // Countries without states/provinces
        }
    }
    
    // Get cities for a country and state/province (or just country if no states)
    static func cities(for country: String, state: String) -> [String] {
        switch country {
        case "United States":
            return statesAndCities[state]?.sorted() ?? []
        case "Canada":
            return canadianProvincesAndCities[state]?.sorted() ?? []
        case "United Kingdom":
            return ukRegionsAndCities[state]?.sorted() ?? []
        case "Australia":
            return australianStatesAndCities[state]?.sorted() ?? []
        default:
            return majorCitiesByCountry[country]?.sorted() ?? []
        }
    }
    
    // Check if a country uses states/provinces
    static func usesStates(country: String) -> Bool {
        return ["United States", "Canada", "United Kingdom", "Australia"].contains(country)
    }
}

