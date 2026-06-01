//
//  ShareViewController.swift
//  Share Extension
//
//  Receives links/text/images shared into Stix from other apps (TikTok,
//  Instagram, etc.) and hands them to the Flutter app via receive_sharing_intent.
//
import receive_sharing_intent

class ShareViewController: RSIShareViewController {

    // Return false so the share sheet doesn't auto-close before redirecting.
    override func shouldAutoRedirect() -> Bool {
        return false
    }

    // Label the confirm button "Save to Stix".
    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Save to Stix"
    }
}
