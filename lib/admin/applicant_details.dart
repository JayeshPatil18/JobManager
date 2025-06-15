import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_manager/services/job_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicantDetailsPage extends StatefulWidget {
  final Map<String, dynamic> applicant;

  const ApplicantDetailsPage({super.key, required this.applicant});

  @override
  State<ApplicantDetailsPage> createState() => _ApplicantDetailsPageState();
}

class _ApplicantDetailsPageState extends State<ApplicantDetailsPage> {
  late String currentStatus;
  final List<String> statusOptions = [
    'Pending',
    'Shortlisted',
    'Interview Scheduled',
    'Selected',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    final statusFromData = widget.applicant['status'] ?? 'Pending';
    if (statusOptions.contains(statusFromData)) {
      currentStatus = statusFromData;
    } else {
      currentStatus = 'Pending'; // fallback if unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    var appliedAt = (widget.applicant['appliedAt'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            Text(
              '${widget.applicant['name']}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dashboard.jpg"),
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
                  // Personal Details Card
                  _buildCard([
                    _infoText('Name', widget.applicant['name']),
                    _infoText('Status', currentStatus),
                    _infoText('Phone', widget.applicant['phone']),
                    _infoText('Email', widget.applicant['email']),
                    _infoText('Home Address', widget.applicant['homeAddress']),
                    _infoText('Notice Period', widget.applicant['noticePeriod']),
                    _infoText('Counter Offer', widget.applicant['counterOffer']),
                    _infoText('Applied At', appliedAt.toLocal().toString()),
                  ]),

                  // Status Update Radio Buttons
                  _buildCard([
                    const Text("Update Application Status", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...statusOptions.map((status) => RadioListTile(
                      title: Text(status),
                      value: status,
                      groupValue: currentStatus,
                      onChanged: (value) {
                        setState(() {
                          currentStatus = value!;
                        });
                      },
                    )),
                    ElevatedButton(
                      onPressed: _updateStatus,
                      child: const Text("Save Status"),
                    ),
                  ]),

                  // Resume and Cover Letter
                  _buildCard([
                    _infoText('Cover Letter URL', widget.applicant['coverLetter']),
                    _infoText('Resume URL', widget.applicant['resumeURL']),
                  ]),

                  // LinkedIn and GitHub
                  _buildCard([
                    _infoText('LinkedIn', widget.applicant['linkedinURL']),
                    _infoText('GitHub', widget.applicant['githubURL']),
                  ]),

                  // Buttons in two rows
                  _buildButtonRow([
                    _buildLinkButton('LinkedIn', Icons.link, widget.applicant['linkedinURL']),
                    _buildLinkButton('GitHub', Icons.code, widget.applicant['githubURL']),
                  ]),
                  const SizedBox(height: 8),
                  _buildButtonRow([
                    _buildLinkButton('Resume', Icons.document_scanner, widget.applicant['resumeURL']),
                    _buildLinkButton('Cover Letter', Icons.description, widget.applicant['coverLetter']),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return Row(
      children: buttons
          .map((button) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: button)))
          .toList(),
    );
  }

  Widget _buildLinkButton(String label, IconData icon, String url) {
    return ElevatedButton.icon(
      onPressed: () => _openUrl(context, url),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError(context, 'Could not open the link');
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _updateStatus() async {
    try {
      JobService _jobService = JobService();
      await _jobService.updateApplicantStatus(widget.applicant['applicantId'], currentStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')),
      );
    } catch (e) {
      _showError(context, 'Failed to update status: $e');
    }
  }
}
