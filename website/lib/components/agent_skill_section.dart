import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'copy_button.dart';

/// A compact band pointing coding agents at `skills/keyed_form/SKILL.md`.
/// Installs into the cross-agent `.agents/skills/` folder; Claude Code
/// reads `.claude/skills/`, hence the symlink line.
class AgentSkillSection extends StatelessComponent {
  const AgentSkillSection({super.key});

  static const _skillUrl = 'https://raw.githubusercontent.com/iamv4g/keyed_form/main/skills/keyed_form/SKILL.md';

  static const _install =
      'mkdir -p .agents/skills/keyed_form && \\\n'
      '  curl -fsSL $_skillUrl \\\n'
      '  -o .agents/skills/keyed_form/SKILL.md';

  static const _claudeLink =
      'mkdir -p .claude/skills && ln -s ../../.agents/skills/keyed_form .claude/skills/keyed_form';

  @override
  Component build(BuildContext context) {
    return section(id: 'agent-skill', classes: 'wrap', [
      div(classes: 'skill-box blueprint-box', [
        div(classes: 'skill-copy', [
          span(classes: 'section-kicker mono', [.text('// AGENT SKILL')]),
          h2(classes: 'section-title display', [.text('Your coding agent already speaks keyed_form.')]),
          p(classes: 'section-lede', [
            .text(
              'A ready-made Agent Skill teaches your coding agent the schema DSL, field refs, dynamic lists and '
              'submit flow — so "add a list of stops with a required city" comes out idiomatic on the first try. '
              'Works with any agent that supports Agent Skills.',
            ),
          ]),
          a(
            classes: 'section-link mono',
            href: 'https://github.com/iamv4g/keyed_form/blob/main/skills/keyed_form/SKILL.md',
            target: Target.blank,
            [.text('Read SKILL.md →')],
          ),
        ]),
        div(classes: 'skill-install', [
          div(classes: 'cmd-block', [
            pre(classes: 'mono', [
              code([.text(_install)]),
            ]),
            const CopyButton(text: _install),
          ]),
          p(classes: 'skill-note mono', [.text('Using Claude Code? Link it:')]),
          div(classes: 'cmd-block', [
            pre(classes: 'mono', [
              code([.text(_claudeLink)]),
            ]),
            const CopyButton(text: _claudeLink),
          ]),
        ]),
      ]),
    ]);
  }
}
