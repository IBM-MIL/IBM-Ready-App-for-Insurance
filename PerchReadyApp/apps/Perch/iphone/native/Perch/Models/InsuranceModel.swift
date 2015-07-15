/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  This models the Insurance policy plan. This included the policy number, the insurance agent information, and the insurance itemized info
*/
class InsuranceModel: NSObject {
    var policyNumber = ""
    var companyName = ""
    var agentImage: UIImage?
    var agentName = ""
    var phoneNumber = ""
    var emailAddress = ""
    var location = ""
    var insuranceItems: [InsuranceCoverageItem] = []
    var creditItems: [InsuranceCreditItem] = []
    
    func generateFakeInsurance() {
        policyNumber = "12-34-5678-9"
        companyName = "Rainy Insurance Co. Agent"
        agentName = "Max Robinson"
        phoneNumber = "1118675309"
        emailAddress = "insuranceAgent@insurance.com"
        location = "11501 Burnet Road, Austin, TX 78758"
        agentImage = UIImage(named: "agent_headshot")
        
        // Insurance Items
        var item = InsuranceCoverageItem(coverage: "Dwelling", coverageLimit: 345000, coveragePremium: 1503)
        insuranceItems.append(item)
        item = InsuranceCoverageItem(coverage: "Other Structure", coverageLimit: 34500, coveragePremium: 0)
        insuranceItems.append(item)
        item = InsuranceCoverageItem(coverage: "Personal Property", coverageLimit: 241500, coveragePremium: 0)
        insuranceItems.append(item)
        item = InsuranceCoverageItem(coverage: "Loss of Use", coverageLimit: 103500, coveragePremium: 0)
        insuranceItems.append(item)
        item = InsuranceCoverageItem(coverage: "Personal Liability", coverageLimit: 500000, coveragePremium: 23)
        insuranceItems.append(item)
        
        // Credit Items
        var creditItem = InsuranceCreditItem(name: "Water Meter Sensor", savings: 10)
        creditItems.append(creditItem)
        creditItem = InsuranceCreditItem(name: "HVAC Coil Sensor", savings: 18)
        creditItems.append(creditItem)
        creditItem = InsuranceCreditItem(name: "Sewer System Sensor", savings: 10)
        creditItems.append(creditItem)
        
    }
}
