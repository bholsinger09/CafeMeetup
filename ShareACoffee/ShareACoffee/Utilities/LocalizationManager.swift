import Foundation
import SwiftUI
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var appLanguage: String {
        didSet {
            UserDefaults.standard.set(appLanguage, forKey: "appLanguage")
        }
    }
    
    init() {
        self.appLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }
    
    // Translations dictionary
    private let translations: [String: [String: String]] = [
        // Language Selection
        "language.choose": [
            "en": "Choose Language",
            "es": "Elegir Idioma",
            "fr": "Choisir la Langue",
            "de": "Sprache Wählen",
            "it": "Scegli Lingua",
            "pt": "Escolher Idioma",
            "ja": "言語を選択",
            "ko": "언어 선택",
            "zh": "选择语言"
        ],
        // Welcome Screen
        "app.name": [
            "en": "ShareACoffee",
            "es": "Compartir Un Café",
            "fr": "Partager Un Café",
            "de": "Teile Einen Kaffee",
            "it": "Condividi Un Caffè",
            "pt": "Compartilhar Um Café",
            "ja": "コーヒーをシェア",
            "ko": "커피 나누기",
            "zh": "分享咖啡"
        ],
        "welcome.tagline": [
            "en": "Study groups at coffee shops",
            "es": "Grupos de estudio en cafeterías",
            "fr": "Groupes d'étude dans les cafés",
            "de": "Lerngruppen in Cafés",
            "it": "Gruppi di studio nei caffè",
            "pt": "Grupos de estudo em cafés",
            "ja": "カフェでの勉強グループ",
            "ko": "카페에서의 스터디 그룹",
            "zh": "咖啡店学习小组"
        ],
        "welcome.benefit1": [
            "en": "Join study groups by course code",
            "es": "Únete a grupos de estudio por código de curso",
            "fr": "Rejoignez des groupes d'étude par code de cours",
            "de": "Lerngruppen nach Kurscode beitreten",
            "it": "Unisciti a gruppi di studio per codice corso",
            "pt": "Junte-se a grupos de estudo por código de curso",
            "ja": "コースコードで学習グループに参加",
            "ko": "과목 코드로 스터디 그룹 참여",
            "zh": "通过课程代码加入学习小组"
        ],
        "welcome.benefit2": [
            "en": "Study at coffee shops near you",
            "es": "Estudia en cafeterías cerca de ti",
            "fr": "Étudiez dans les cafés près de chez vous",
            "de": "Lernen Sie in Cafés in Ihrer Nähe",
            "it": "Studia nei caffè vicino a te",
            "pt": "Estude em cafés perto de você",
            "ja": "近くのカフェで勉強",
            "ko": "근처 카페에서 공부하기",
            "zh": "在您附近的咖啡店学习"
        ],
        "welcome.benefit3": [
            "en": "Collaborate with 3+ students",
            "es": "Colabora con 3+ estudiantes",
            "fr": "Collaborez avec 3+ étudiants",
            "de": "Zusammenarbeit mit 3+ Studenten",
            "it": "Collabora con 3+ studenti",
            "pt": "Colabore com 3+ alunos",
            "ja": "3人以上の学生と協力",
            "ko": "3명 이상의 학생들과 협력",
            "zh": "与3名以上学生合作"
        ],
        "button.getStarted": [
            "en": "Get Started",
            "es": "Comenzar",
            "fr": "Commencer",
            "de": "Loslegen",
            "it": "Inizia",
            "pt": "Começar",
            "ja": "始める",
            "ko": "시작하기",
            "zh": "开始"
        ],
        "button.signIn": [
            "en": "Sign In",
            "es": "Iniciar Sesión",
            "fr": "Se Connecter",
            "de": "Anmelden",
            "it": "Accedi",
            "pt": "Entrar",
            "ja": "サインイン",
            "ko": "로그인",
            "zh": "登录"
        ],
        // Profile
        "profile.country": [
            "en": "Country",
            "es": "País",
            "fr": "Pays",
            "de": "Land",
            "it": "Paese",
            "pt": "País",
            "ja": "国",
            "ko": "국가",
            "zh": "国家"
        ],
        "profile.state": [
            "en": "State",
            "es": "Estado",
            "fr": "État",
            "de": "Bundesland",
            "it": "Stato",
            "pt": "Estado",
            "ja": "州",
            "ko": "주",
            "zh": "州"
        ],
        "profile.city": [
            "en": "City",
            "es": "Ciudad",
            "fr": "Ville",
            "de": "Stadt",
            "it": "Città",
            "pt": "Cidade",
            "ja": "市",
            "ko": "도시",
            "zh": "城市"
        ]
    ]
    
    func localized(_ key: String) -> String {
        return translations[key]?[appLanguage] ?? translations[key]?["en"] ?? key
    }
}

// SwiftUI View extension for easy localization
extension View {
    func localized(_ key: String) -> String {
        LocalizationManager.shared.localized(key)
    }
}
