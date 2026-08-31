Periodical background jobs in `hroot` handle automated processes such as sending out scheduled experiment invitations, invitation digests, session reminders, incoming email polling, survey timeout checks, Kimai synchronization, and user inactivity warnings.

### Managing Cronjobs with Whenever (Manual / Bare-Metal Deployments)

For managing periodic tasks, `hroot` uses the [whenever](https://github.com/javan/whenever) gem, which automatically translates the schedule defined in `config/schedule.rb` into crontab entries.

#### View Configured Tasks
To preview the generated cron syntax without applying it, run:
```bash
bundle exec whenever
```

#### Apply and Update Crontab
To write or update the active cron jobs for your production environment:
```bash
RAILS_ENV=production bundle exec whenever --update-crontab
```

#### Clear Crontab
If you are moving the application or switching to Docker, remove the registered cron entries:
```bash
RAILS_ENV=production bundle exec whenever --clear-crontab
```

---

### Key Scheduled Background Tasks

| Interval | Task / Runner | Description |
| :--- | :--- | :--- |
| **Every 2 min** | `FetchIncomingEmailsJob.perform_now` | Polls configured IMAP mailbox for participant email responses. |
| **Every 5 min** | `ScheduledInvitation.process_queue` | Dispatches timed experiment invitations. |
| **Every 5 min** | `DigestInvitation.process_queue` | Sends grouped invitation digests. |
| **Every 5 min** | `Task.run_tasks` | General scheduled task runner. |
| **Every 5 min** | `CheckSurveyTimeoutsJob.perform_later` | Automatically closes expired survey participations. |
| **Twice daily (4:00, 16:00)** | `KimaiSyncJob.perform_later` | Synchronizes projects, sessions, and time tracking with Kimai. |
| **Daily (18:00)** | `PendingShiftPlanNotification` | Sends pending duty shift plan updates to laboratory staff. |
| **Daily (Midnight)** | `OneYearReminders.*` | Sends account inactivity warnings and disables inactive users after 1 year. |
| **Daily (Midnight)** | `Experiment.run_automatch` | Automatically matches waitlist participants if enabled. |

---

### Docker Deployments

In Docker environments, cron jobs are automatically managed by the dedicated **`cron` container** defined in `docker-compose.yml` (`./docker/cron-entrypoint.sh`). No manual crontab entries on the host machine are necessary.

