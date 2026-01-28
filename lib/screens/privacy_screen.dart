
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_footer.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: SelectableText(
              '''New Life Community Church, Tonyrefail is committed to safeguarding your privacy. Contact us at nlcctonyrefail@hotmail.com if you have any questions or problems regarding the use of your Personal Data and we will gladly assist you.

By using this site or/and our services, you consent to the Processing of your Personal Data as described in this Privacy Policy.

Table of Contents
Definitions used in this Policy
Data protection principles we follow
What rights do you have regarding your Personal Data
What Personal Data we gather about you
How we use your Personal Data
Who else has access to your Personal Data
How we secure your data
Information about cookies
Contact information
Definitions
Personal Data – any information relating to an identified or identifiable natural person.
Processing – any operation or set of operations which is performed on Personal Data or on sets of Personal Data.
Data subject – a natural person whose Personal Data is being Processed.
Child – a natural person under 16 years of age.

Data Protection Principles
We promise to follow the following data protection principles:

Processing is lawful, fair, transparent. Our Processing activities have lawful grounds. We always consider your rights before Processing Personal Data. We will provide you information regarding Processing upon request.
Processing is limited to the purpose. Our Processing activities fit the purpose for which Personal Data was gathered.
Processing is done with minimal data. We only gather and Process the minimal amount of Personal Data required for any purpose.
Processing is limited with a time period. We will not store your personal data for longer than needed.
We will do our best to ensure the accuracy of data.
We will do our best to ensure the integrity and confidentiality of data.
Data Subject’s rights
The Data Subject has the following rights:

Right to information – meaning you have to right to know whether your Personal Data is being processed; what data is gathered, from where it is obtained and why and by whom it is processed.
Right to access – meaning you have the right to access the data collected from/about you. This includes your right to request and obtain a copy of your Personal Data gathered.
Right to rectification – meaning you have the right to request rectification or erasure of your Personal Data that is inaccurate or incomplete.
Right to erasure – meaning in certain circumstances you can request for your Personal Data to be erased from our records.
Right to restrict processing – meaning where certain conditions apply, you have the right to restrict the Processing of your Personal Data.
Right to object to processing – meaning in certain cases you have the right to object to Processing of your Personal Data, for example in the case of direct marketing.
Right to object to automated Processing – meaning you have the right to object to automated Processing, including profiling; and not to be subject to a decision based solely on automated Processing. This right you can exercise whenever there is an outcome of the profiling that produces legal effects concerning or significantly affecting you.
Right to data portability – you have the right to obtain your Personal Data in a machine-readable format or if it is feasible, as a direct transfer from one Processor to another.
Right to lodge a complaint – in the event that we refuse your request under the Rights of Access, we will provide you with a reason as to why. If you are not satisfied with the way your request has been handled please contact us.
Right for the help of supervisory authority – meaning you have the right for the help of a supervisory authority and the right for other legal remedies such as claiming damages.
Right to withdraw consent – you have the right withdraw any given consent for Processing of your Personal Data.
Data we gather at New Life Community Church, Tonyrefail
 Information you have provided us with-
This might be your e-mail address, name, billing address, home address etc – mainly information that is necessary for delivering you a product/service or to enhance your customer experience with us. We save the information you provide us with in order for you to comment or perform other activities on the website. This information includes, for example, your name and e-mail address.

Information automatically collected about you
This includes information that is automatically stored by cookies and other session tools. For example, your shopping cart information, your IP address, your shopping history (if there is any) etc. This information is used to improve your customer experience. When you use our services or look at the contents of our website, your activities may be logged.

Information from our partners
We gather information from our trusted partners with confirmation that they have legal grounds to share that information with us. This is either information you have provided them directly with or that they have gathered about you on other legal grounds. See the list of our partners here.

Following is a list of our Partners –

C.A.B – Communities for Work – Hafal Clic – Interlink – M.I.N.D – Neighbourly Surplus Food Lidl – Safe Families for Children – Slimming World – The Rainbow Trust – The Co op – Veterans’ HUB Rhondda – W.I Tonyrefail

Publicly available information
We might gather information about you that is publicly available.

How we use your Personal Data
We use your Personal Data in order to:

provide our service to you. This includes for example registering your account; providing you with other services that you have requested; providing you with promotional items at your request and communicating with you in relation to those products and services; communicating and interacting with you; and notifying you of changes to any services.
NLCC – will use your Personal Data on legitimate grounds only with your Consent.
On the grounds of entering into a contract or fulfilling contractual obligations, we Process your Personal Data for the following purposes:

to identify you;
to provide you a service with our Partners in agreement with yourself
On the ground of legitimate interest, we Process your Personal Data for the following purposes:

to send you personalized offers* (from us and/or our carefully selected partners);
to administer and analyse our client base  in order to improve the quality, variety, and availability of products/ services offered/provided;
to conduct questionnaires concerning client satisfaction with NLCC
As long as you have not informed us otherwise, we consider offering you services that are similar or same to your behaviour to be our legitimate interest.

With your consent we Process your Personal Data for the following purposes:

to send you newsletters from us ;
for other purposes we have asked your consent for;
We Process your Personal Data in order to fulfil obligation rising from law and/or use your Personal Data for options provided by law. We save your information and other information gathered about you for as long as needed for accounting purposes or other obligations deriving from law, but not longer than 42 days.

We might process your Personal Data for additional purposes that are not mentioned here, but are compatible with the original purpose for which the data was gathered. To do this, we will ensure that:

the link between purposes, context and nature of Personal Data is suitable for further Processing;
the further Processing would not harm your interests and
there would be appropriate safeguard for Processing.
We will inform you of any further Processing and purposes.

Who else can access your Personal Data
We do not share your Personal Data with strangers. Personal Data about you is in some cases provided to our trusted partners in order to either make providing the service to you possible or to enhance your customer experience. We share your data with:

Our processing partners:

[ Interlink – C.A.B. – The Rainbow Trust – M.I.N.D – Safe Families for Children –
Halfal Clic ]
Our business partners:

[ The Coop – Neighbourly Surplus Food Lidl ]
Connected third parties:

[ Communities for Work – Veterans’ HUB Rhondda – W.I Tonyrefail – Slimming
World ]
We only work with Processing partners who are able to ensure adequate level of protection to your Personal Data. We disclose your Personal Data to third parties or public officials when we are legally obliged to do so. We might disclose your Personal Data to third parties if you have consented to it or if there are other legal grounds for it.

How we secure your data
We do our best to keep your Personal Data safe.  We use safe protocols for communication and transferring data (such as HTTPS). We use anonymising and pseudonymising where suitable. We monitor our systems for possible vulnerabilities and attacks. Additional security measures includes the shredding of your details after 42 days and deletion from our I.T system.

Even though we try our best we can not guarantee the security of information. However, we promise to notify suitable authorities of data breaches. We will also notify you if there is a threat to your rights or interests. We will do everything we reasonably can to prevent security breaches and to assist authorities should any breaches occur.

Children
We do not intend to collect or knowingly collect information from children. Be assured we do not target children with our services.

Cookies and other technologies we use
We use cookies and/or similar technologies to analyse customer behaviour, administer the website, track users’ movements, and to collect information about users.

A cookie is a tiny text file stored on your computer. Cookies store information that is used to help make sites work. Only we can access the cookies created by our website. You can control your cookies at the browser level. Choosing to disable cookies may hinder your use of certain functions.

We use cookies for the following purposes:

Necessary cookies – these cookies are required for you to be able to use some important features on our website, such as logging in. These cookies don’t collect any personal information.
Functionality cookies – these cookies provide functionality that makes using our service more convenient and makes providing more personalised features possible. For example, they might remember your name and e-mail in comment forms so you don’t have to re-enter this information next time when commenting.
Analytics cookies – these cookies are used to track the use and performance of our website and services
Advertising cookies – we do not use these at all under any circumstances.
You can remove cookies stored in your computer via your browser settings. For more information about cookies, visit allaboutcookies.org

We use Google Analytics to measure traffic on our website. Google has their own Privacy Policy . If you’d like to opt out of tracking by Google Analytics, visit the Google Analytics opt-out page.

Contact Information
a/ nlcctonyrefail@hotmail.com / nlcc.hub1@yahoo.com

b/ Supervisory Authority
The Trustees of New Life Community Church, Tonyrefail

Changes to this Privacy Policy
We reserve the right to make change to this Privacy Policy.
Last modification was made 23rd April 2019.

 

PB/DP 23/04/2019''',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
    );
  }
}
