import Foundation
import SwiftData

/// Today ekranı için gerekli tüm verileri tek bir seferde hazırlayan Use Case.
/// ViewModel'deki iş mantığını buraya taşıyoruz.
@MainActor
protocol TodayOverviewUseCaseProtocol {
    func execute() async -> TodayOverviewData
}

struct TodayOverviewData {
    let activeSemester: Semester?
    let nextClass: NextClassResult?
    let todayClasses: [(session: ClassSession, period: PeriodDefinition)]
    let currentClass: (session: ClassSession, period: PeriodDefinition)?
    let isInstructionalDay: Bool
}

@MainActor
final class TodayOverviewUseCase: TodayOverviewUseCaseProtocol {
    private let schoolDayEngine: any SchoolDayCalculating
    private let nextClassCalculator: any NextClassProviding
    private let todayScheduleProvider: any TodayScheduleProviding
    
    init(
        schoolDayEngine: any SchoolDayCalculating,
        nextClassCalculator: any NextClassProviding,
        todayScheduleProvider: any TodayScheduleProviding
    ) {
        self.schoolDayEngine = schoolDayEngine
        self.nextClassCalculator = nextClassCalculator
        self.todayScheduleProvider = todayScheduleProvider
    }
    
    func execute() async -> TodayOverviewData {
        let semester = schoolDayEngine.getActiveSemester()
        let today = Date()
        
        guard let semester = semester else {
            return TodayOverviewData(
                activeSemester: nil,
                nextClass: nil,
                todayClasses: [],
                currentClass: nil,
                isInstructionalDay: false
            )
        }
        
        let isInstructionalDay = schoolDayEngine.isInstructionalDay(today, semester: semester)
        
        var todayClasses: [(session: ClassSession, period: PeriodDefinition)] = []
        var currentClass: (session: ClassSession, period: PeriodDefinition)?
        
        if isInstructionalDay {
            todayClasses = await todayScheduleProvider.todayClassesWithPeriods(semester: semester)
            currentClass = await todayScheduleProvider.currentClass(semester: semester)
        }
        
        let nextClass = await nextClassCalculator.nextClass(from: today, semester: semester)
        
        return TodayOverviewData(
            activeSemester: semester,
            nextClass: nextClass,
            todayClasses: todayClasses,
            currentClass: currentClass,
            isInstructionalDay: isInstructionalDay
        )
    }
}
