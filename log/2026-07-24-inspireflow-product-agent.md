# inspireFlow Product Agent and Scope Log

Date: 2026-07-24

## User-visible result

- Added a workspace custom Agent named `inspireFlow Product Engineer` for focused SwiftUI product implementation and review.
- Defined the creator journey from inspiration capture through a complete project, plus the separate brand collaboration journey.
- Added product requirements for post-registration creator profile setup, an explicitly published public workshop, one-way brand interest, and asymmetric contact visibility.
- Established a living frontend handoff document for teammate integration.

## Files changed

- `.github/agents/inspireflow-product.agent.md`
- `TODO.md`
- `FRONTEND-HANDOFF.md`
- `log/2026-07-24-inspireflow-product-agent.md`

## Agent behavior added

- SwiftUI and native iOS integration are the default scope.
- Teammate-owned backend, RingSDK Python and Injective execution are changed only when explicitly requested and when a contract is available.
- Every user-facing implementation receives a product-manager review covering primary task, journey timing, navigation, consent, effort and alternate states.
- Every completed implementation session must add a dated log under `log/`.
- Integration-facing changes must update `FRONTEND-HANDOFF.md`.

## Contract and model decisions

- Profile completion does not imply public workshop publication.
- Creator contact disclosure is explicit and may be scoped per field.
- A brand may view authorized creator contact methods.
- A creator may see which brand followed or expressed interest and the stated intent, but does not receive the brand's contact details through this feature.
- Private inspirations, recordings, PAWN turns and drafts are not public by default.

## Validation

- Parsed the Agent YAML frontmatter successfully with Ruby YAML.
- Confirmed the required description and tool list are present.
- Ran `git diff --check` on the Agent file with no whitespace errors.
- Inspected current `AppSession`, `AppStore`, creator navigation, client navigation and backend handoff before documenting the baseline.

## Known limitations

- This session creates configuration and product/integration documentation only; it does not implement profile, workshop or brand-interest SwiftUI screens.
- Backend endpoints for account, profile, workshop and brand interest are requirements, not confirmed implementations.
- Physical device and Injective behavior remain outside this Agent's default autonomous scope.

## Next integration step

Implement structured creator profile and visibility models plus the post-registration profile setup flow, using a local service protocol and fixtures that can later be replaced by the teammate's account API.