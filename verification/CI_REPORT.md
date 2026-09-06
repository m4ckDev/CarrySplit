# Carry Splits CI Verification

- Commit: `ad1093c2a2fe834124c01da4d9ec4f65dd815c94`
- Xcode: `Xcode 26.6 Build version 17F113 `
- Simulator UDID: `6EE862FE-93F2-4D55-946E-8745EE2B3A88`
- Result: **PASS**

## xcodebuild tail

```text
CoreData: error: addPersistentStoreWithType:configuration:URL:options:error: returned error NSCocoaErrorDomain (512)
2026-09-06 01:44:20.057410+0000 CarrySplits[5231:22116] [error] CoreData: error: userInfo:
CoreData: error: userInfo:
2026-09-06 01:44:20.057472+0000 CarrySplits[5231:22116] [error] CoreData: error: 	reason : Failed to create file; code = 2
CoreData: error: 	reason : Failed to create file; code = 2
2026-09-06 01:44:20.057555+0000 CarrySplits[5231:22116] [error] CoreData: error: storeType: SQLite
CoreData: error: storeType: SQLite
2026-09-06 01:44:20.057676+0000 CarrySplits[5231:22116] [error] CoreData: error: configuration: default
CoreData: error: configuration: default
2026-09-06 01:44:20.057872+0000 CarrySplits[5231:22116] [error] CoreData: error: URL: file:///Users/runner/Library/Developer/CoreSimulator/Devices/6EE862FE-93F2-4D55-946E-8745EE2B3A88/data/Containers/Data/Application/B2990DEB-5952-4508-80E3-53C555D1D95C/Library/Application%20Support/default.store
CoreData: error: URL: file:///Users/runner/Library/Developer/CoreSimulator/Devices/6EE862FE-93F2-4D55-946E-8745EE2B3A88/data/Containers/Data/Application/B2990DEB-5952-4508-80E3-53C555D1D95C/Library/Application%20Support/default.store
CoreData: annotation: options:
CoreData: annotation: 	NSMigratePersistentStoresAutomaticallyOption : 1
CoreData: annotation: 	NSInferMappingModelAutomaticallyOption : 1
CoreData: annotation: 	NSPersistentStoreRemoteChangeNotificationOptionKey : 1
CoreData: annotation: 	NSPersistentHistoryTrackingKey : 1
2026-09-06 01:44:20.060202+0000 CarrySplits[5231:22116] [error] CoreData: error: <NSPersistentStoreCoordinator: 0x105b88480>: Attempting recovery from error encountered during addPersistentStore: 0x105b0e220 Error Domain=NSCocoaErrorDomain Code=512 "The file couldn’t be saved." UserInfo={reason=Failed to create file; code = 2}
CoreData: error: <NSPersistentStoreCoordinator: 0x105b88480>: Attempting recovery from error encountered during addPersistentStore: 0x105b0e220 Error Domain=NSCocoaErrorDomain Code=512 "The file couldn’t be saved." UserInfo={reason=Failed to create file; code = 2}
2026-09-06 01:44:20.062211+0000 CarrySplits[5231:22116] [error] CoreData: error: During recovery, parent directory path reported as missing
CoreData: error: During recovery, parent directory path reported as missing
2026-09-06 01:44:20.081233+0000 CarrySplits[5231:22116] [error] CoreData: error: Recovery attempt while adding <NSPersistentStoreDescription: 0x105b0e220> (type: SQLite, url: file:///Users/runner/Library/Developer/CoreSimulator/Devices/6EE862FE-93F2-4D55-946E-8745EE2B3A88/data/Containers/Data/Application/B2990DEB-5952-4508-80E3-53C555D1D95C/Library/Application%20Support/default.store) was successful!
CoreData: error: Recovery attempt while adding <NSPersistentStoreDescription: 0x105b0e220> (type: SQLite, url: file:///Users/runner/Library/Developer/CoreSimulator/Devices/6EE862FE-93F2-4D55-946E-8745EE2B3A88/data/Containers/Data/Application/B2990DEB-5952-4508-80E3-53C555D1D95C/Library/Application%20Support/default.store) was successful!
Test Suite 'All tests' started at 2026-09-06 01:44:24.205.
Test Suite 'CarrySplitsTests.xctest' started at 2026-09-06 01:44:24.206.
Test Suite 'PersistenceTests' started at 2026-09-06 01:44:24.206.
Test Case '-[CarrySplitsTests.PersistenceTests testCompleteLedgerReloadsIntoFreshModelContext]' started.
Test Case '-[CarrySplitsTests.PersistenceTests testCompleteLedgerReloadsIntoFreshModelContext]' passed (0.058 seconds).
Test Case '-[CarrySplitsTests.PersistenceTests testDeletingSplitRemovesItFromFreshContext]' started.
Test Case '-[CarrySplitsTests.PersistenceTests testDeletingSplitRemovesItFromFreshContext]' passed (0.017 seconds).
Test Case '-[CarrySplitsTests.PersistenceTests testParticipantReferencedByExpenseCannotBeDeletedUntilExpenseIsRemoved]' started.
Test Case '-[CarrySplitsTests.PersistenceTests testParticipantReferencedByExpenseCannotBeDeletedUntilExpenseIsRemoved]' passed (0.026 seconds).
Test Case '-[CarrySplitsTests.PersistenceTests testRenameArchiveAndParticipantRenamePersistAcrossReload]' started.
Test Case '-[CarrySplitsTests.PersistenceTests testRenameArchiveAndParticipantRenamePersistAcrossReload]' passed (0.018 seconds).
Test Suite 'PersistenceTests' passed at 2026-09-06 01:44:24.328.
	 Executed 4 tests, with 0 failures (0 unexpected) in 0.120 (0.121) seconds
Test Suite 'SettlementServiceTests' started at 2026-09-06 01:44:24.338.
Test Case '-[CarrySplitsTests.SettlementServiceTests testBalancesCarryForwardAcrossMultiplePayers]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testBalancesCarryForwardAcrossMultiplePayers]' passed (0.002 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testCompletedSettlementMovesBalancesTowardZero]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testCompletedSettlementMovesBalancesTowardZero]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testEqualSplitDistributesRemainderAndPreservesTotal]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testEqualSplitDistributesRemainderAndPreservesTotal]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testEqualSplitSupportsZeroDecimalCurrency]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testEqualSplitSupportsZeroDecimalCurrency]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testExactSplitRejectsAllocationTotalMismatch]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testExactSplitRejectsAllocationTotalMismatch]' passed (0.002 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testLedgerRejectsUnknownParticipant]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testLedgerRejectsUnknownParticipant]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testSettlementPlanPrioritizesExactBalanceMatches]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testSettlementPlanPrioritizesExactBalanceMatches]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testSettlementPlanProducesExpectedTransfers]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testSettlementPlanProducesExpectedTransfers]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementServiceTests testSettlementPlanRejectsUnbalancedInput]' started.
Test Case '-[CarrySplitsTests.SettlementServiceTests testSettlementPlanRejectsUnbalancedInput]' passed (0.000 seconds).
Test Suite 'SettlementServiceTests' passed at 2026-09-06 01:44:28.125.
	 Executed 9 tests, with 0 failures (0 unexpected) in 0.009 (3.787) seconds
Test Suite 'SettlementSummaryServiceTests' started at 2026-09-06 01:44:28.125.
Test Case '-[CarrySplitsTests.SettlementSummaryServiceTests testSummaryListsCurrentSettlementTransfers]' started.
Test Case '-[CarrySplitsTests.SettlementSummaryServiceTests testSummaryListsCurrentSettlementTransfers]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementSummaryServiceTests testSummaryReportsAllSettled]' started.
Test Case '-[CarrySplitsTests.SettlementSummaryServiceTests testSummaryReportsAllSettled]' passed (0.001 seconds).
Test Case '-[CarrySplitsTests.SettlementSummaryServiceTests testSummaryReportsNothingToSettleWithoutExpenses]' started.
Test Case '-[CarrySplitsTests.SettlementSummaryServiceTests testSummaryReportsNothingToSettleWithoutExpenses]' passed (0.001 seconds).
Test Suite 'SettlementSummaryServiceTests' passed at 2026-09-06 01:44:28.819.
	 Executed 3 tests, with 0 failures (0 unexpected) in 0.003 (0.694) seconds
Test Suite 'SplitsViewModelTests' started at 2026-09-06 01:44:28.819.
Test Case '-[CarrySplitsTests.SplitsViewModelTests testCompleteEqualSplitWorkflowSettlesToZero]' started.
Test Case '-[CarrySplitsTests.SplitsViewModelTests testCompleteEqualSplitWorkflowSettlesToZero]' passed (0.750 seconds).
Test Case '-[CarrySplitsTests.SplitsViewModelTests testDuplicateParticipantNameIsRejectedCaseInsensitively]' started.
Test Case '-[CarrySplitsTests.SplitsViewModelTests testDuplicateParticipantNameIsRejectedCaseInsensitively]' passed (0.011 seconds).
Test Case '-[CarrySplitsTests.SplitsViewModelTests testEditingExpenseRecalculatesBalances]' started.
Test Case '-[CarrySplitsTests.SplitsViewModelTests testEditingExpenseRecalculatesBalances]' passed (0.019 seconds).
Test Suite 'SplitsViewModelTests' passed at 2026-09-06 01:44:29.600.
	 Executed 3 tests, with 0 failures (0 unexpected) in 0.780 (0.781) seconds
Test Suite 'CarrySplitsTests.xctest' passed at 2026-09-06 01:44:29.600.
	 Executed 19 tests, with 0 failures (0 unexpected) in 0.911 (5.394) seconds
Test Suite 'All tests' passed at 2026-09-06 01:44:29.663.
	 Executed 19 tests, with 0 failures (0 unexpected) in 0.911 (5.459) seconds
2026-09-06 01:44:38.510926+0000 CarrySplitsUITests-Runner[6206:25772] [Default] Running tests...
2026-09-06 01:44:38.583764+0000 CarrySplitsUITests-Runner[6206:25816] [General] Failed to send CA Event for app launch measurements for ca_event_type: 0 event_name: com.apple.app_launch_measurement.FirstFramePresentationMetric
2026-09-06 01:44:38.628558+0000 CarrySplitsUITests-Runner[6206:25810] [General] Failed to send CA Event for app launch measurements for ca_event_type: 1 event_name: com.apple.app_launch_measurement.ExtendedLaunchMetrics
objc[6206]: Class UIAccessibilityLoaderWebShared is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebCore.axbundle/WebCore (0x1057b0310) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebKit.axbundle/WebKit (0x1085dc398). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
    t =      nans Interface orientation changed to Portrait
Test Suite 'All tests' started at 2026-09-06 01:44:49.232.
Test Suite 'CarrySplitsUITests.xctest' started at 2026-09-06 01:44:49.234.
Test Suite 'CarrySplitsUITests' started at 2026-09-06 01:44:49.235.
Test Case '-[CarrySplitsUITests.CarrySplitsUITests testCreateSplitPersistsAcrossRelaunch]' started.
    t =     0.00s Start Test at 2026-09-06 01:44:49.235
    t =     1.20s Set Up
    t =     1.21s Open com.m4ckdev.CarrySplits
    t =     1.21s     Launch com.m4ckdev.CarrySplits
2026-09-06 01:44:54.191 xcodebuild[3445:15234] [MT] IDELaunchParametersSnapshot: The operation couldn’t be completed. (DebuggerLLDB.DebuggerVersionStore.StoreError error 0.)
2026-09-06 01:44:54.191 xcodebuild[3445:15234] [MT] IDELaunchParametersSnapshot: no debugger version
    t =     6.93s         Setting up automation session
    t =     8.15s         Wait for com.m4ckdev.CarrySplits to idle
    t =    10.10s Waiting 10.0s for "splits.new" Button to exist
    t =    11.16s     Checking `Expect predicate `existsNoRetry == 1` for object "splits.new" Button`
    t =    11.16s         Checking existence of `"splits.new" Button`
    t =    11.22s Tap "splits.new" Button
    t =    11.22s     Wait for com.m4ckdev.CarrySplits to idle
    t =    11.23s     Find the "splits.new" Button
    t =    11.26s     Check for interrupting elements affecting "splits.new" Button
    t =    11.31s     Synthesize event
    t =    11.74s     Wait for com.m4ckdev.CarrySplits to idle
    t =    12.71s Waiting 5.0s for "createSplit.name" TextField to exist
    t =    13.76s     Checking `Expect predicate `existsNoRetry == 1` for object "createSplit.name" TextField`
    t =    13.76s         Checking existence of `"createSplit.name" TextField`
    t =    14.46s Tap "createSplit.name" TextField
    t =    14.46s     Wait for com.m4ckdev.CarrySplits to idle
    t =    14.46s     Find the "createSplit.name" TextField
    t =    14.54s     Check for interrupting elements affecting "createSplit.name" TextField
    t =    14.64s     Synthesize event
    t =    14.94s     Wait for com.m4ckdev.CarrySplits to idle
    t =    14.94s Type 'UI Persist 1F6C48F8' into "createSplit.name" TextField
    t =    14.94s     Wait for com.m4ckdev.CarrySplits to idle
    t =    14.94s     Find the "createSplit.name" TextField
    t =    15.38s     Check for interrupting elements affecting "createSplit.name" TextField
    t =    15.54s     Synthesize event
    t =    16.06s     Wait for com.m4ckdev.CarrySplits to idle
    t =    16.11s Find the "createSplit.create" Button
    t =    16.29s Tap "createSplit.create" Button
    t =    16.29s     Wait for com.m4ckdev.CarrySplits to idle
    t =    16.29s     Find the "createSplit.create" Button
    t =    16.39s     Check for interrupting elements affecting "createSplit.create" Button
    t =    16.49s     Synthesize event
    t =    16.81s     Wait for com.m4ckdev.CarrySplits to idle
    t =    17.86s Waiting 5.0s for Button (First Match) to exist
    t =    18.91s     Checking `Expect predicate `existsNoRetry == 1` for object Button (First Match)`
    t =    18.91s         Checking existence of `Button (First Match)`
    t =    19.05s Terminate com.m4ckdev.CarrySplits:6843
    t =    20.12s Open com.m4ckdev.CarrySplits
    t =    20.12s     Launch com.m4ckdev.CarrySplits
2026-09-06 01:45:09.363 xcodebuild[3445:15234] [MT] IDELaunchParametersSnapshot: The operation couldn’t be completed. (DebuggerLLDB.DebuggerVersionStore.StoreError error 0.)
2026-09-06 01:45:09.363 xcodebuild[3445:15234] [MT] IDELaunchParametersSnapshot: no debugger version
    t =    21.32s         Setting up automation session
    t =    22.03s         Wait for com.m4ckdev.CarrySplits to idle
    t =    23.77s Waiting 10.0s for "splits.new" Button to exist
    t =    24.80s     Checking `Expect predicate `existsNoRetry == 1` for object "splits.new" Button`
    t =    24.80s         Checking existence of `"splits.new" Button`
    t =    24.90s Waiting 10.0s for Button (First Match) to exist
    t =    25.94s     Checking `Expect predicate `existsNoRetry == 1` for object Button (First Match)`
    t =    25.94s         Checking existence of `Button (First Match)`
    t =    26.04s Tear Down
Test Case '-[CarrySplitsUITests.CarrySplitsUITests testCreateSplitPersistsAcrossRelaunch]' passed (36.362 seconds).
Test Suite 'CarrySplitsUITests' passed at 2026-09-06 01:45:25.600.
	 Executed 1 test, with 0 failures (0 unexpected) in 36.362 (36.365) seconds
Test Suite 'CarrySplitsUITests.xctest' passed at 2026-09-06 01:45:25.600.
	 Executed 1 test, with 0 failures (0 unexpected) in 36.362 (36.366) seconds
Test Suite 'All tests' passed at 2026-09-06 01:45:25.600.
	 Executed 1 test, with 0 failures (0 unexpected) in 36.362 (36.368) seconds
2026-09-06 01:45:26.218 xcodebuild[3445:15234] [MT] IDETestOperationsObserverDebug: 180.530 elapsed -- Testing started completed.
2026-09-06 01:45:26.218 xcodebuild[3445:15234] [MT] IDETestOperationsObserverDebug: 0.000 sec, +0.000 sec -- start
2026-09-06 01:45:26.218 xcodebuild[3445:15234] [MT] IDETestOperationsObserverDebug: 180.530 sec, +180.530 sec -- end

Test session results, code coverage, and logs:
	/Users/runner/work/CarrySplit/CarrySplit/verification/CarrySplits.xcresult

** TEST SUCCEEDED **

Testing started
```
