//
//  Analytics.swift
//  catchup
//
//  Created by Sidhant Gandhi on 9/5/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

func captureError(_ error: Error? = nil, message: String? = nil) {
    let errorMessage = "\(message ?? "generic error") - \(error?.localizedDescription ?? "no description")"
    print(errorMessage)
    #if canImport(FirebaseAnalytics)
    Analytics.logEvent(AnalyticsEvent.Error.rawValue, parameters: [AnalyticsParameter.ErrorMessage.rawValue: errorMessage])
    #endif

}
enum AnalyticsEvent: String {
    case Error
    case NewCatchupCreated
    case CatchupDeleteSwipe
    case MaxCatchupsReached
    case UpdateTapped
    case NewCatchupTapped
    case NewCatchupCancelTapped
    case SettingsTapped
    case SettingsCancelTapped
    case SettingsSaveTapped
    case NotificationTapped
}

enum AnalyticsParameter: String {
    case ErrorMessage
    case CatchupMethod
    case CatchupInterval
    case CatchupDate
    case SettingsDuration
    case CatchupsCount
    case SettingsWeekdayTimeslots
    case SettingsWeekendTimeslots
    case Timezone
    case NotificationAction
}
