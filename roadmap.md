# Future Improvement Roadmap

## Phase 4: Polish & Production Readiness (Immediate Next Steps)
- [ ] **Page Transitions**: Custom slide/fade transitions using GoRouter `pageBuilder`.
- [ ] **Micro-interactions**: Add `flutter_animate` to all buttons and list items.
- [ ] **Responsive Layout**: Ensure acceptable layout on Tablet/Web (use `LayoutBuilder`).
- [ ] **Error Boundary**: Global error handling widget.

## Phase 5: Legacy Migration
- [ ] **Migrate Tasks Feature**: Move `TaskProvider` logic to `TaskNotifier` (Riverpod).
- [ ] **Migrate Calendar**: Move `CalendarPage` to Clean Architecture.
- [ ] **Remove `Provider`**: Once all migrations are done, remove `provider` dependency and `MultiProvider` from `main.dart`.

## Phase 6: Advanced SaaS Features
- [ ] **Subscription System**: Integrate Stripe/RevenueCat for Premium/Pro plans.
- [ ] **Team/Collaboration**: simple "Study Groups" using subcollections.
- [ ] **AI Enhancements**: Connect `GeminiService` to user context (tasks, schedule).

## Performance Optimization
- [ ] **Image Caching**: Use `cached_network_image` for profile pics.
- [ ] **Pagination**: Implement pagination for Task history.
