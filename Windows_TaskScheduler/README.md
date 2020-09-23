Library of module(s) destined to Windows Task Scheduler monitoring

### - Windows_TaskScheduler_RunStatus (DataSource)

> Retrieve the list of Scheduled Tasks that aren't in 'Disabled' state
> Groups instance automatically by the actual task folder (using auto.TaskPath property)
- Filter(s) can be used to grab only specific tasks and/or group(s) of tasks [using the auto.TaskPath property]

#### Currently monitoring:
- lastExitCode
- NumberOfMissedRuns

##### Future Developments:

- Get more task detail(s) if it suits the needs
- Add a more comprehensive view of the task last run code(s), since LM appears to be changing the actual output
[WIKI](https://docs.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-error-and-success-constants)
- For now we're alarming on task(s) that have the exit code '!= 0'