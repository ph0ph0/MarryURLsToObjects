import UIKit

class Product {

    var GTIN: Double?
    var brand: String?
    var model: String?
    var desc: String?
    var price: Double?
    var size: [String]?
    var category: String?
    var shopName: String?
    var shopID: String?
    var stockLevel: Int?
    var imageURLs: [String]?
    var _geoloc: [String: AnyObject]?
    var instagramProfile: String?
    var shopPhoneNumber: String?
    var openingTimes: String?
    var productCode: String?
    var meta: [String: String]
    var objectID: String!
    var timeStamp: Int!
    var attributes: [String]!

    init?(json: [String: AnyObject]) {
        self.brand = json["Brand"] as! String
        self.model = json["Model"] as? String
        self.desc = json["Desc"] as? String

        //Price is usually stored as "£xx.xx" in JSON. We need to remove the £, if it has one, and convert to double.
        self.price = json["Price"] as! Double

        self.size = json["Size"] as? [String]
        self.category = json["Category"] as? String
        self.shopName = json["ShopName"] as? String
        self.shopID = json["ShopID"] as? String
        self.stockLevel = json["StockLevel"] as? Int
        self.imageURLs = json["ImageURLs"] as? [String]
        self._geoloc = json["_geoloc"] as! [String: AnyObject]
        self.instagramProfile = json["InstagramProfile"] as? String
        self.shopPhoneNumber = json["ShopPhoneNumber"] as! String
        self.openingTimes = json["OpeningTimes"] as! String
        self.productCode = json["ProductCode"] as? String
        self.meta = json["Meta"] as! [String: String]!
        self.objectID = json["objectID"] as! String
        self.timeStamp = json["Timestamp"] as? Int
        self.attributes = json["Attributes"] as? [String]

//                print(self.brand,
//                      self.model,
//                      self.desc,
//                      self.price,
//                      self.size,
//                      self.category,
//                      self.shopName,
//                      self.shopID,
//                      self.stockLevel,
//                      self.imageURLs,
//                      self._geoloc,
//                      self.instagramProfile,
//                      self.shopPhoneNumber,
//                      self.openingTimes,
//                      self.productCode,
//                      self.meta,
//                      self.objectID
//                )

    }
}

//Create Path for the JSON file located in resources
let productJSONPath = Bundle.main.path(forResource: "productJSON", ofType: "json")
let imageURLsJSONPath = Bundle.main.path(forResource: "urls", ofType: "json")

//Convert file location (path) to json Data
let preprocessedProductJSON = try Data(contentsOf: URL(fileURLWithPath: productJSONPath!))
//let preprocessedImageURLsJSON = try Data(contentsOf: URL(fileURLWithPath: imageURLsJSONPath!))

//Parse the product data into swift dictionary
var parsedProductsJSONArray = try! JSONSerialization.jsonObject(with: preprocessedProductJSON, options: .allowFragments) as! [String: AnyObject]
//Initialise the urlArray
let urlsArray = urls.init()
let storageURLs = urlsArray.strings

var jsonString = String()

let arrayOfKeys = parsedProductsJSONArray.keys

for key in arrayOfKeys {
    let productDetails = parsedProductsJSONArray[key] as! [String: AnyObject]
    let product = Product(json: productDetails)
    
    let keyArray = key.split(separator: ":")
    let hashValue = keyArray[1]
    
    //print(hashValue)
    
    var urlArray = [String]()
    for url in storageURLs {
        if url.contains(String(hashValue)) {
            urlArray.append(url)
            //print("match")
        } else {
            //print("NO MATCH: \(url)")
        }
    }
    
    //We need to ensure that the only products that are uploaded to Firestore are those with images. If the imageArray is empty, then it means that no images were downloaded for it and as such it should not be uploaded to Firestore.
    if urlArray.isEmpty {
        //print("breaking")
        continue
    }
    
    let newProductJSON = [
    
            key : [
    
                "Brand" : product!.brand!,
                "Model" : product!.model,
                "Price" : product!.price,
                "Size" : product!.size,
                "Category" : product!.category!,
                "ShopName" : product!.shopName!,
                "ImageURLs" : urlArray,
                "_geoloc": product!._geoloc!,
                "objectID": key,
                "ShopID": product!.shopID!,
                "Desc": product!.desc,
                "InstagramProfile": product!.instagramProfile,
                "ShopPhoneNumber": product!.shopPhoneNumber!,
                "OpeningTimes": product!.openingTimes!,
                "ProductCode": product!.productCode,
                "Meta": product!.meta,
                "TimeStamp": product!.timeStamp,
                "Attributes": product!.attributes
    
            ]
        ]
    
    //Turn the JSON data into a string, this can be converted to CSV data (string with data separated by comma's), but is also easier to debug. We need to remove double curly brackets, and also get rid of ’ and replace these with '''
        if JSONSerialization.isValidJSONObject(newProductJSON) {
    
            do {
    
                if let data = try? JSONSerialization.data(withJSONObject: newProductJSON, options: []) {
                    let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    let newString = string?.replacingOccurrences(of: "}}", with: "},")
    
                    jsonString += newString!
    
                }
            }
        } else {
            print("Not real JSON")
        }
}

//Do some final editing then the string is finished.
let finalJSONstring = jsonString.replacingOccurrences(of: "},{", with: "},")
let finalFinalJSONstring = finalJSONstring.replacingOccurrences(of: "[{", with: "{")
let finalFinalFinalJSONstring = finalFinalJSONstring.replacingOccurrences(of: "}]", with: "}")
let finalFinalFinalFinalJSONstring = finalFinalFinalJSONstring.replacingOccurrences(of: ",h", with: "\", \"h")

print(finalFinalFinalFinalJSONstring)


