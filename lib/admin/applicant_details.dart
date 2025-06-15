import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> applicant;

  const ApplicantDetailsPage({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    // Convert appliedAt timestamp to DateTime
    var appliedAt = (applicant['appliedAt'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white), // White icon
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            Text(
              '${applicant['name']}',
              style: TextStyle(color: Colors.white), // White title text color
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple, // Consistent background color
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dashboard.jpg"), // Set your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Applicant's Name and Details Section
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${applicant['name']}',
                              style: Theme.of(context).textTheme.headline6),
                          const SizedBox(height: 8),
                          Text('Status: ${applicant['status']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text('Phone: ${applicant['phone']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text('Email: ${applicant['email']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text('Home Address: ${applicant['homeAddress']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text('Notice Period: ${applicant['noticePeriod']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text('Counter Offer: ${applicant['counterOffer']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text(
                              'Applied At: ${appliedAt.toLocal()}',
                              style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                    ),
                  ),

                  // Resume and Cover Letter Links
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cover Letter: ${applicant['coverLetter']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text('Resume URL: ${applicant['resumeURL']}',
                              style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                    ),
                  ),

                  // LinkedIn and GitHub Links
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LinkedIn: ${applicant['linkedinURL']}',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 8),
                          Text('GitHub: ${applicant['githubURL']}',
                              style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                    ),
                  ),

                  // Buttons to open LinkedIn, GitHub, Resume links, and Cover Letter
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _openUrl(context, applicant['linkedinURL']),
                                icon: const Icon(Icons.link),
                                label: const Text('LinkedIn'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _openUrl(context, applicant['githubURL']),
                                icon: const Icon(Icons.code),
                                label: const Text('GitHub'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _openUrl(context, applicant['resumeURL']),
                                icon: const Icon(Icons.document_scanner),
                                label: const Text('Resume'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _openUrl(context, applicant['coverLetter']),
                                icon: const Icon(Icons.description),
                                label: const Text('Cover Letter'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to open a URL (LinkedIn, GitHub, Resume, Cover Letter)
  Future<void> _openUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError(context, 'Could not open the link');
    }
  }

  // Method to show error message
  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
