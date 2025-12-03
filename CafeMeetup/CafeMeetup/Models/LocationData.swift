import Foundation

struct LocationData {
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
    
    static let states = statesAndCities.keys.sorted()
    
    static func cities(for state: String) -> [String] {
        return statesAndCities[state]?.sorted() ?? []
    }
}
