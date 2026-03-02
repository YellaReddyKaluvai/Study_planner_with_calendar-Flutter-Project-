import 'package:flutter/material.dart';

/// App-wide string translations.
/// Usage: AppStrings.of(context).welcome
/// Falls back to English for any missing key.
class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  String get _lang => locale.languageCode;

  String _t(Map<String, String> translations) {
    return translations[_lang] ?? translations['en'] ?? '';
  }

  // ─── Common ────────────────────────────────────────────────────────────────
  String get appName => _t({'en': 'Study Planner', 'hi': 'अध्ययन योजनाकार', 'es': 'Planificador de Estudio', 'fr': 'Planificateur d\'Étude', 'de': 'Studienplaner', 'zh': '学习计划器', 'ar': 'مخطط الدراسة', 'ja': '学習プランナー', 'pt': 'Planejador de Estudo', 'ko': '학습 플래너'});
  String get save => _t({'en': 'Save', 'hi': 'सहेजें', 'es': 'Guardar', 'fr': 'Sauvegarder', 'de': 'Speichern', 'zh': '保存', 'ar': 'حفظ', 'ja': '保存', 'pt': 'Salvar', 'ko': '저장'});
  String get cancel => _t({'en': 'Cancel', 'hi': 'रद्द करें', 'es': 'Cancelar', 'fr': 'Annuler', 'de': 'Abbrechen', 'zh': '取消', 'ar': 'إلغاء', 'ja': 'キャンセル', 'pt': 'Cancelar', 'ko': '취소'});
  String get ok => _t({'en': 'OK', 'hi': 'ठीक है', 'es': 'Aceptar', 'fr': 'OK', 'de': 'OK', 'zh': '确定', 'ar': 'موافق', 'ja': 'OK', 'pt': 'OK', 'ko': '확인'});
  String get close => _t({'en': 'Close', 'hi': 'बंद करें', 'es': 'Cerrar', 'fr': 'Fermer', 'de': 'Schließen', 'zh': '关闭', 'ar': 'إغلاق', 'ja': '閉じる', 'pt': 'Fechar', 'ko': '닫기'});
  String get loading => _t({'en': 'Loading...', 'hi': 'लोड हो रहा है...', 'es': 'Cargando...', 'fr': 'Chargement...', 'de': 'Laden...', 'zh': '加载中...', 'ar': 'جار التحميل...', 'ja': '読み込み中...', 'pt': 'Carregando...', 'ko': '로딩 중...'});

  // ─── Nav Bar ───────────────────────────────────────────────────────────────
  String get navHome => _t({'en': 'Home', 'hi': 'होम', 'es': 'Inicio', 'fr': 'Accueil', 'de': 'Startseite', 'zh': '首页', 'ar': 'الرئيسية', 'ja': 'ホーム', 'pt': 'Início', 'ko': '홈'});
  String get navTasks => _t({'en': 'Tasks', 'hi': 'कार्य', 'es': 'Tareas', 'fr': 'Tâches', 'de': 'Aufgaben', 'zh': '任务', 'ar': 'المهام', 'ja': 'タスク', 'pt': 'Tarefas', 'ko': '작업'});
  String get navCalendar => _t({'en': 'Calendar', 'hi': 'कैलेंडर', 'es': 'Calendario', 'fr': 'Calendrier', 'de': 'Kalender', 'zh': '日历', 'ar': 'التقويم', 'ja': 'カレンダー', 'pt': 'Calendário', 'ko': '캘린더'});
  String get navAnalytics => _t({'en': 'Analytics', 'hi': 'विश्लेषण', 'es': 'Analíticas', 'fr': 'Analytiques', 'de': 'Analytik', 'zh': '分析', 'ar': 'التحليلات', 'ja': '分析', 'pt': 'Análise', 'ko': '분석'});
  String get navProfile => _t({'en': 'Profile', 'hi': 'प्रोफ़ाइल', 'es': 'Perfil', 'fr': 'Profil', 'de': 'Profil', 'zh': '个人资料', 'ar': 'الملف الشخصي', 'ja': 'プロフィール', 'pt': 'Perfil', 'ko': '프로필'});
  String get navChat => _t({'en': 'AI Chat', 'hi': 'AI चैट', 'es': 'Chat IA', 'fr': 'Chat IA', 'de': 'KI-Chat', 'zh': 'AI聊天', 'ar': 'دردشة AI', 'ja': 'AIチャット', 'pt': 'Chat IA', 'ko': 'AI 채팅'});

  // ─── Profile / Settings ────────────────────────────────────────────────────
  String get accountStats => _t({'en': 'Account Stats', 'hi': 'खाता आँकड़े', 'es': 'Estadísticas de Cuenta', 'fr': 'Statistiques du Compte', 'de': 'Kontostatistiken', 'zh': '账户统计', 'ar': 'إحصائيات الحساب', 'ja': 'アカウント統計', 'pt': 'Estatísticas da Conta', 'ko': '계정 통계'});
  String get joined => _t({'en': 'Joined', 'hi': 'शामिल हुए', 'es': 'Unido', 'fr': 'Rejoint', 'de': 'Beigetreten', 'zh': '加入时间', 'ar': 'انضم', 'ja': '参加日', 'pt': 'Ingressou', 'ko': '가입일'});
  String get lastLogin => _t({'en': 'Last Login', 'hi': 'अंतिम लॉगिन', 'es': 'Último Acceso', 'fr': 'Dernière Connexion', 'de': 'Letzter Login', 'zh': '最后登录', 'ar': 'آخر دخول', 'ja': '最終ログイン', 'pt': 'Último Acesso', 'ko': '마지막 로그인'});
  String get settings => _t({'en': 'Settings', 'hi': 'सेटिंग्स', 'es': 'Configuración', 'fr': 'Paramètres', 'de': 'Einstellungen', 'zh': '设置', 'ar': 'الإعدادات', 'ja': '設定', 'pt': 'Configurações', 'ko': '설정'});
  String get darkMode => _t({'en': 'Dark Mode', 'hi': 'डार्क मोड', 'es': 'Modo Oscuro', 'fr': 'Mode Sombre', 'de': 'Dunkelmodus', 'zh': '深色模式', 'ar': 'الوضع المظلم', 'ja': 'ダークモード', 'pt': 'Modo Escuro', 'ko': '다크 모드'});
  String get darkModeOn => _t({'en': 'On', 'hi': 'चालू', 'es': 'Activado', 'fr': 'Activé', 'de': 'An', 'zh': '开', 'ar': 'تشغيل', 'ja': 'オン', 'pt': 'Ligado', 'ko': '켜짐'});
  String get darkModeOff => _t({'en': 'Off', 'hi': 'बंद', 'es': 'Desactivado', 'fr': 'Désactivé', 'de': 'Aus', 'zh': '关', 'ar': 'إيقاف', 'ja': 'オフ', 'pt': 'Desligado', 'ko': '꺼짐'});
  String get notifications => _t({'en': 'Notifications', 'hi': 'सूचनाएं', 'es': 'Notificaciones', 'fr': 'Notifications', 'de': 'Benachrichtigungen', 'zh': '通知', 'ar': 'الإشعارات', 'ja': '通知', 'pt': 'Notificações', 'ko': '알림'});
  String get manageAlerts => _t({'en': 'Manage alerts & reminders', 'hi': 'अलर्ट और अनुस्मारक प्रबंधित करें', 'es': 'Gestionar alertas y recordatorios', 'fr': 'Gérer les alertes et rappels', 'de': 'Benachrichtigungen & Erinnerungen verwalten', 'zh': '管理提醒和通知', 'ar': 'إدارة التنبيهات والتذكيرات', 'ja': 'アラートとリマインダーを管理', 'pt': 'Gerenciar alertas e lembretes', 'ko': '알림 및 알람 관리'});
  String get language => _t({'en': 'Language', 'hi': 'भाषा', 'es': 'Idioma', 'fr': 'Langue', 'de': 'Sprache', 'zh': '语言', 'ar': 'اللغة', 'ja': '言語', 'pt': 'Idioma', 'ko': '언어'});
  String get selectLanguage => _t({'en': 'Select Language', 'hi': 'भाषा चुनें', 'es': 'Seleccionar Idioma', 'fr': 'Choisir la Langue', 'de': 'Sprache wählen', 'zh': '选择语言', 'ar': 'اختر اللغة', 'ja': '言語を選択', 'pt': 'Selecionar Idioma', 'ko': '언어 선택'});
  String get privacy => _t({'en': 'Privacy', 'hi': 'गोपनीयता', 'es': 'Privacidad', 'fr': 'Confidentialité', 'de': 'Datenschutz', 'zh': '隐私', 'ar': 'الخصوصية', 'ja': 'プライバシー', 'pt': 'Privacidade', 'ko': '개인정보'});
  String get passwordAndSecurity => _t({'en': 'Password & Security', 'hi': 'पासवर्ड और सुरक्षा', 'es': 'Contraseña y Seguridad', 'fr': 'Mot de passe et Sécurité', 'de': 'Passwort & Sicherheit', 'zh': '密码与安全', 'ar': 'كلمة المرور والأمان', 'ja': 'パスワードとセキュリティ', 'pt': 'Senha e Segurança', 'ko': '비밀번호 및 보안'});
  String get signOut => _t({'en': 'Sign Out', 'hi': 'साइन आउट', 'es': 'Cerrar Sesión', 'fr': 'Se Déconnecter', 'de': 'Abmelden', 'zh': '退出登录', 'ar': 'تسجيل الخروج', 'ja': 'サインアウト', 'pt': 'Sair', 'ko': '로그아웃'});
  String get editName => _t({'en': 'Edit Name', 'hi': 'नाम संपादित करें', 'es': 'Editar Nombre', 'fr': 'Modifier le Nom', 'de': 'Namen bearbeiten', 'zh': '编辑名字', 'ar': 'تعديل الاسم', 'ja': '名前を編集', 'pt': 'Editar Nome', 'ko': '이름 편집'});
  String get enterNewName => _t({'en': 'Enter new name', 'hi': 'नया नाम दर्ज करें', 'es': 'Ingrese el nuevo nombre', 'fr': 'Entrer un nouveau nom', 'de': 'Neuen Namen eingeben', 'zh': '输入新名字', 'ar': 'أدخل الاسم الجديد', 'ja': '新しい名前を入力', 'pt': 'Inserir novo nome', 'ko': '새 이름 입력'});

  // ─── Privacy ───────────────────────────────────────────────────────────────
  String get changePassword => _t({'en': 'Change Password', 'hi': 'पासवर्ड बदलें', 'es': 'Cambiar Contraseña', 'fr': 'Changer le mot de passe', 'de': 'Passwort ändern', 'zh': '更改密码', 'ar': 'تغيير كلمة المرور', 'ja': 'パスワード変更', 'pt': 'Alterar Senha', 'ko': '비밀번호 변경'});
  String get currentPassword => _t({'en': 'Current Password', 'hi': 'वर्तमान पासवर्ड', 'es': 'Contraseña Actual', 'fr': 'Mot de Passe Actuel', 'de': 'Aktuelles Passwort', 'zh': '当前密码', 'ar': 'كلمة المرور الحالية', 'ja': '現在のパスワード', 'pt': 'Senha Atual', 'ko': '현재 비밀번호'});
  String get newPassword => _t({'en': 'New Password', 'hi': 'नया पासवर्ड', 'es': 'Nueva Contraseña', 'fr': 'Nouveau Mot de Passe', 'de': 'Neues Passwort', 'zh': '新密码', 'ar': 'كلمة المرور الجديدة', 'ja': '新しいパスワード', 'pt': 'Nova Senha', 'ko': '새 비밀번호'});
  String get confirmPassword => _t({'en': 'Confirm Password', 'hi': 'पासवर्ड पुष्टि करें', 'es': 'Confirmar Contraseña', 'fr': 'Confirmer le Mot de Passe', 'de': 'Passwort bestätigen', 'zh': '确认密码', 'ar': 'تأكيد كلمة المرور', 'ja': 'パスワード確認', 'pt': 'Confirmar Senha', 'ko': '비밀번호 확인'});
  String get twoFactorAuth => _t({'en': 'Two-Factor Auth', 'hi': 'दो-कारक प्रमाणीकरण', 'es': 'Autenticación de Dos Factores', 'fr': 'Authentification à Deux Facteurs', 'de': 'Zwei-Faktor-Auth', 'zh': '两步验证', 'ar': 'المصادقة الثنائية', 'ja': '二段階認証', 'pt': 'Autenticação em Dois Fatores', 'ko': '이중 인증'});
  String get deleteAccount => _t({'en': 'Delete Account', 'hi': 'खाता हटाएं', 'es': 'Eliminar Cuenta', 'fr': 'Supprimer le Compte', 'de': 'Konto löschen', 'zh': '删除账户', 'ar': 'حذف الحساب', 'ja': 'アカウントを削除', 'pt': 'Excluir Conta', 'ko': '계정 삭제'});

  // ─── Notifications Settings ────────────────────────────────────────────────
  String get taskReminders => _t({'en': 'Task Reminders', 'hi': 'कार्य अनुस्मारक', 'es': 'Recordatorios de Tareas', 'fr': 'Rappels de Tâches', 'de': 'Aufgabenerinnerungen', 'zh': '任务提醒', 'ar': 'تذكيرات المهام', 'ja': 'タスクリマインダー', 'pt': 'Lembretes de Tarefas', 'ko': '작업 알림'});
  String get studyStreak => _t({'en': 'Study Streak Alerts', 'hi': 'अध्ययन स्ट्रीक अलर्ट', 'es': 'Alertas de Racha de Estudio', 'fr': 'Alertes de Série d\'Étude', 'de': 'Lernanreihe-Benachrichtigungen', 'zh': '学习连击提醒', 'ar': 'تنبيهات سلسلة الدراسة', 'ja': '学習ストリーク通知', 'pt': 'Alertas de Sequência de Estudo', 'ko': '학습 연속 알림'});
  String get xpRewards => _t({'en': 'XP & Reward Alerts', 'hi': 'XP और पुरस्कार अलर्ट', 'es': 'Alertas de XP y Recompensas', 'fr': 'Alertes XP et Récompenses', 'de': 'XP & Belohnungsbenachrichtigungen', 'zh': 'XP和奖励提醒', 'ar': 'تنبيهات نقاط XP والمكافآت', 'ja': 'XP・報酬通知', 'pt': 'Alertas de XP e Recompensas', 'ko': 'XP 및 보상 알림'});
  String get dailyDigest => _t({'en': 'Daily Digest', 'hi': 'दैनिक सारांश', 'es': 'Resumen Diario', 'fr': 'Résumé Quotidien', 'de': 'Tägliche Zusammenfassung', 'zh': '每日摘要', 'ar': 'الملخص اليومي', 'ja': 'デイリーダイジェスト', 'pt': 'Resumo Diário', 'ko': '일일 요약'});
  String get testNotification => _t({'en': 'Send Test Notification', 'hi': 'परीक्षण सूचना भेजें', 'es': 'Enviar Notificación de Prueba', 'fr': 'Envoyer une Notification Test', 'de': 'Testbenachrichtigung senden', 'zh': '发送测试通知', 'ar': 'إرسال إشعار تجريبي', 'ja': 'テスト通知を送信', 'pt': 'Enviar Notificação de Teste', 'ko': '테스트 알림 보내기'});
  String get notificationSettings => _t({'en': 'Notification Settings', 'hi': 'सूचना सेटिंग्स', 'es': 'Configuración de Notificaciones', 'fr': 'Paramètres de Notification', 'de': 'Benachrichtigungseinstellungen', 'zh': '通知设置', 'ar': 'إعدادات الإشعارات', 'ja': '通知設定', 'pt': 'Configurações de Notificação', 'ko': '알림 설정'});

  // ─── Tasks ─────────────────────────────────────────────────────────────────
  String get todaysTasks => _t({'en': "Today's Tasks", 'hi': 'आज के कार्य', 'es': 'Tareas de Hoy', 'fr': "Tâches d'Aujourd'hui", 'de': 'Heutige Aufgaben', 'zh': '今天的任务', 'ar': 'مهام اليوم', 'ja': '今日のタスク', 'pt': 'Tarefas de Hoje', 'ko': '오늘의 작업'});
  String get newTask => _t({'en': 'New Task', 'hi': 'नया कार्य', 'es': 'Nueva Tarea', 'fr': 'Nouvelle Tâche', 'de': 'Neue Aufgabe', 'zh': '新任务', 'ar': 'مهمة جديدة', 'ja': '新しいタスク', 'pt': 'Nova Tarefa', 'ko': '새 작업'});
  String get editTask => _t({'en': 'Edit Task', 'hi': 'कार्य संपादित करें', 'es': 'Editar Tarea', 'fr': 'Modifier la Tâche', 'de': 'Aufgabe bearbeiten', 'zh': '编辑任务', 'ar': 'تعديل المهمة', 'ja': 'タスクを編集', 'pt': 'Editar Tarefa', 'ko': '작업 편집'});
  String get noTasks => _t({'en': 'No tasks yet!', 'hi': 'अभी कोई कार्य नहीं!', 'es': '¡No hay tareas aún!', 'fr': "Pas encore de tâches !", 'de': 'Noch keine Aufgaben!', 'zh': '暂无任务！', 'ar': 'لا توجد مهام بعد!', 'ja': 'まだタスクがありません！', 'pt': 'Nenhuma tarefa ainda!', 'ko': '아직 작업이 없습니다!'});
  String get addFirstTask => _t({'en': 'Add your first task to get started', 'hi': 'शुरू करने के लिए अपना पहला कार्य जोड़ें', 'es': 'Agrega tu primera tarea para comenzar', 'fr': 'Ajoutez votre première tâche pour commencer', 'de': 'Füge deine erste Aufgabe hinzu, um zu beginnen', 'zh': '添加第一个任务以开始', 'ar': 'أضف مهمتك الأولى للبدء', 'ja': '最初のタスクを追加して始めましょう', 'pt': 'Adicione sua primeira tarefa para começar', 'ko': '첫 번째 작업을 추가하여 시작하세요'});

  // ─── Home / Greeting ───────────────────────────────────────────────────────
  String get goodMorning => _t({'en': 'Good Morning', 'hi': 'सुप्रभात', 'es': 'Buenos Días', 'fr': 'Bonjour', 'de': 'Guten Morgen', 'zh': '早上好', 'ar': 'صباح الخير', 'ja': 'おはようございます', 'pt': 'Bom Dia', 'ko': '좋은 아침이에요'});
  String get goodAfternoon => _t({'en': 'Good Afternoon', 'hi': 'शुभ दोपहर', 'es': 'Buenas Tardes', 'fr': 'Bon Après-midi', 'de': 'Guten Nachmittag', 'zh': '下午好', 'ar': 'مساء الخير', 'ja': 'こんにちは', 'pt': 'Boa Tarde', 'ko': '좋은 오후예요'});
  String get goodEvening => _t({'en': 'Good Evening', 'hi': 'शुभ संध्या', 'es': 'Buenas Noches', 'fr': 'Bonsoir', 'de': 'Guten Abend', 'zh': '晚上好', 'ar': 'مساء الخير', 'ja': 'こんばんは', 'pt': 'Boa Noite', 'ko': '좋은 저녁이에요'});

  // ─── Analytics & Home ──────────────────────────────────────────────────────
  String get quickStats => _t({'en': 'Quick Stats', 'hi': 'त्वरित आँकड़े', 'es': 'Estadísticas Rápidas', 'fr': 'Statistiques Rapides', 'de': 'Schnelle Statistiken', 'zh': '快速统计', 'ar': 'إحصائيات سريعة', 'ja': 'クイック統計', 'pt': 'Estatísticas Rápidas', 'ko': '빠른 통계'});
  String get tasksDone => _t({'en': 'Tasks Done', 'hi': 'पूर्ण कार्य', 'es': 'Tareas Realizadas', 'fr': 'Tâches Terminées', 'de': 'Erledigte Aufgaben', 'zh': '已完成任务', 'ar': 'المهام المنجزة', 'ja': '完了タスク', 'pt': 'Tarefas Concluídas', 'ko': '완료된 작업'});
  String get totalTasks => _t({'en': 'Total Tasks', 'hi': 'कुल कार्य', 'es': 'Tareas Totales', 'fr': 'Tâches Totales', 'de': 'Gesamtaufgaben', 'zh': '总任务', 'ar': 'إجمالي المهام', 'ja': '合計タスク', 'pt': 'Total de Tarefas', 'ko': '총 작업'});
  String get focusTime => _t({'en': 'Focus Time', 'hi': 'फ़ोकस समय', 'es': 'Tiempo de Enfoque', 'fr': 'Temps de Concentration', 'de': 'Fokuszeit', 'zh': '专注时间', 'ar': 'وقت التركيز', 'ja': '集中時間', 'pt': 'Tempo de Foco', 'ko': '집중 시간'});
  String get totalLogged => _t({'en': 'total logged', 'hi': 'कुल लॉग किया गया', 'es': 'total registrado', 'fr': 'total enregistré', 'de': 'insgesamt erfasst', 'zh': '总计记录', 'ar': 'إجمالي المسجل', 'ja': '合計記録', 'pt': 'total registrado', 'ko': '총 기록'});
  String get avgSession => _t({'en': 'Avg Session', 'hi': 'औसत सत्र', 'es': 'Sesión Promedio', 'fr': 'Session Moyenne', 'de': 'Durchschnittssitzung', 'zh': '平均会话', 'ar': 'متوسط الجلسة', 'ja': '平均セッション', 'pt': 'Sessão Média', 'ko': '평균 세션'});
  String get perSession => _t({'en': 'per session', 'hi': 'प्रति सत्र', 'es': 'por sesión', 'fr': 'par session', 'de': 'pro Sitzung', 'zh': '每次会话', 'ar': 'لكل جلسة', 'ja': 'セッションごと', 'pt': 'por sessão', 'ko': '세션당'});
  String get weeklyProgress => _t({'en': 'Weekly Progress', 'hi': 'साप्ताहिक प्रगति', 'es': 'Progreso Semanal', 'fr': 'Progrès Hebdomadaire', 'de': 'Wöchentlicher Fortschritt', 'zh': '每周进度', 'ar': 'التقدم الأسبوعي', 'ja': '週間進捗', 'pt': 'Progresso Semanal', 'ko': '주간 진행률'});
  String get totalTime => _t({'en': 'Total Time', 'hi': 'कुल समय', 'es': 'Tiempo Total', 'fr': 'Temps Total', 'de': 'Gesamtzeit', 'zh': '总时间', 'ar': 'الوقت الإجمالي', 'ja': '合計時間', 'pt': 'Tempo Total', 'ko': '총 시간'});
  String get currentStreak => _t({'en': 'Current Streak', 'hi': 'वर्तमान स्ट्रीक', 'es': 'Racha Actual', 'fr': 'Série Actuelle', 'de': 'Aktuelle Serie', 'zh': '当前连续', 'ar': 'السلسلة الحالية', 'ja': '現在のストリーク', 'pt': 'Sequência Atual', 'ko': '현재 연속'});
  String get completed => _t({'en': 'Completed', 'hi': 'पूर्ण', 'es': 'Completado', 'fr': 'Terminé', 'de': 'Abgeschlossen', 'zh': '已完成', 'ar': 'مكتمل', 'ja': '完了', 'pt': 'Concluído', 'ko': '완료'});
  String get pending => _t({'en': 'Pending', 'hi': 'लंबित', 'es': 'Pendiente', 'fr': 'En attente', 'de': 'Ausstehend', 'zh': '待完成', 'ar': 'معلق', 'ja': '保留中', 'pt': 'Pendente', 'ko': '대기 중'});
  String get studyHours => _t({'en': 'Study Hours', 'hi': 'अध्ययन घंटे', 'es': 'Horas de Estudio', 'fr': "Heures d'Étude", 'de': 'Lernstunden', 'zh': '学习时间', 'ar': 'ساعات الدراسة', 'ja': '学習時間', 'pt': 'Horas de Estudo', 'ko': '학습 시간'});
  String get streak => _t({'en': 'Streak', 'hi': 'स्ट्रीक', 'es': 'Racha', 'fr': 'Série', 'de': 'Serie', 'zh': '连续', 'ar': 'السلسلة', 'ja': 'ストリーク', 'pt': 'Sequência', 'ko': '연속'});
  String get days => _t({'en': 'days', 'hi': 'दिन', 'es': 'días', 'fr': 'jours', 'de': 'Tage', 'zh': '天', 'ar': 'أيام', 'ja': '日', 'pt': 'dias', 'ko': '일'});
  
  // ─── Gamification ──────────────────────────────────────────────────────────
  String get gameCenter => _t({'en': 'Game Center', 'hi': 'गेम सेंटर', 'es': 'Centro de Juegos', 'fr': 'Centre de Jeux', 'de': 'Spielzentrum', 'zh': '游戏中心', 'ar': 'مركز الألعاب', 'ja': 'ゲームセンター', 'pt': 'Centro de Jogos', 'ko': '게임 센터'});
  String get level => _t({'en': 'Level', 'hi': 'स्तर', 'es': 'Nivel', 'fr': 'Niveau', 'de': 'Level', 'zh': '等级', 'ar': 'مستوى', 'ja': 'レベル', 'pt': 'Nível', 'ko': '레벨'});
  String get levelUp => _t({'en': 'Level Up!', 'hi': 'स्तर बढ़ा!', 'es': '¡Sube de Nivel!', 'fr': 'Niveau Supérieur !', 'de': 'Aufgestiegen!', 'zh': '升级！', 'ar': 'رفع المستوى!', 'ja': 'レベルアップ！', 'pt': 'Subiu de Nível!', 'ko': '레벨 업!'});
  String get youReachedLevel => _t({'en': 'You reached Level', 'hi': 'आप स्तर पर पहुँच गए हैं', 'es': 'Alcanzaste el Nivel', 'fr': 'Vous avez atteint le Niveau', 'de': 'Du hast Level erreicht', 'zh': '你达到了等级', 'ar': 'لقد وصلت إلى المستوى', 'ja': '到達しました レベル', 'pt': 'Você alcançou o Nível', 'ko': '레벨에 도달했습니다'});
  String get awesome => _t({'en': 'Awesome!', 'hi': 'बहुत बढ़िया!', 'es': '¡Impresionante!', 'fr': 'Génial !', 'de': 'Super!', 'zh': '真棒！', 'ar': 'رائع!', 'ja': 'すごい！', 'pt': 'Incrível!', 'ko': '멋져요!'});
  String get totalXp => _t({'en': 'total XP', 'hi': 'कुल एक्सपी', 'es': 'XP total', 'fr': 'XP total', 'de': 'Gesamt-XP', 'zh': '总经验', 'ar': 'إجمالي XP', 'ja': '合計XP', 'pt': 'XP total', 'ko': '총 XP'});
  String get toLevel => _t({'en': 'to Level', 'hi': 'स्तर तक', 'es': 'hasta el Nivel', 'fr': 'au Niveau', 'de': 'bis Level', 'zh': '到等级', 'ar': 'إلى المستوى', 'ja': 'レベルまで', 'pt': 'até o Nível', 'ko': '레벨까지'});
  String get need => _t({'en': 'need', 'hi': 'आवश्यकता', 'es': 'necesitas', 'fr': 'besoin de', 'de': 'benötige', 'zh': '需要', 'ar': 'تحتاج', 'ja': '必要', 'pt': 'precisa', 'ko': '필요'});
  String get moreXp => _t({'en': 'more XP', 'hi': 'और एक्सपी', 'es': 'más XP', 'fr': 'plus d\'XP', 'de': 'mehr XP', 'zh': '更多经验', 'ar': 'مزيد من XP', 'ja': 'もっとXP', 'pt': 'mais XP', 'ko': '더 많은 XP'});

  // ─── AI Chat ───────────────────────────────────────────────────────────────
  String get aiAssistant => _t({'en': 'AI Study Assistant', 'hi': 'AI अध्ययन सहायक', 'es': 'Asistente de Estudio IA', 'fr': "Assistant d'Étude IA", 'de': 'KI-Studienassistent', 'zh': 'AI学习助手', 'ar': 'مساعد الدراسة الذكي', 'ja': 'AI学習アシスタント', 'pt': 'Assistente de Estudo IA', 'ko': 'AI 학습 도우미'});
  String get typeMessage => _t({'en': 'Ask anything about your studies...', 'hi': 'अपनी पढ़ाई के बारे में कुछ भी पूछें...', 'es': 'Pregunta cualquier cosa sobre tus estudios...', 'fr': "Posez n'importe quelle question sur vos études...", 'de': 'Fragen Sie alles über Ihr Studium...', 'zh': '询问有关学习的任何问题...', 'ar': 'اسأل أي شيء عن دراستك...', 'ja': '学習について何でも聞いてください...', 'pt': 'Pergunte qualquer coisa sobre seus estudos...', 'ko': '공부에 관한 모든 것을 물어보세요...'});
  String get clearChat => _t({'en': 'Clear Chat', 'hi': 'चैट साफ़ करें', 'es': 'Limpiar Chat', 'fr': 'Effacer le Chat', 'de': 'Chat löschen', 'zh': '清除聊天', 'ar': 'مسح المحادثة', 'ja': 'チャットをクリア', 'pt': 'Limpar Chat', 'ko': '채팅 지우기'});

  // ─── Calendar ──────────────────────────────────────────────────────────────
  String get noEventsToday => _t({'en': 'No events today', 'hi': 'आज कोई कार्यक्रम नहीं', 'es': 'No hay eventos hoy', 'fr': "Pas d'événements aujourd'hui", 'de': 'Keine Ereignisse heute', 'zh': '今天没有活动', 'ar': 'لا توجد أحداث اليوم', 'ja': '今日の予定はありません', 'pt': 'Nenhum evento hoje', 'ko': '오늘 일정 없음'});
}
