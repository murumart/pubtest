# Jobs
Jobs take input resources and time (consumed) and workers (adjusting how the job goes) and produce an output (resource, effect). Jobs need to be able to be half-completed in case of time or resource shortage. Jobs should be fulfilled concurrently as time passes.

Job representation in memory:

```python
class Job:
	result: Callable
	input_resources: Dictionary
	used_resouces: Dictionary # gets filled as job is completed
	required_time: int # reduces as job is completed
	workers: Array[Worker]

	calculate_completion() -> int
```

In any place where jobs can be viewed there should be a pointer to it. A master list of jobs in DAT. Won't provide save/load in prototype, use Job classes. 

Jobs interface:
```
static Array[Job] jobs; // linked to dat.data[dk.JOBS]

static void pass_time(int amount);
```

Jobs need to be progressed! everywhere in the player's world as time passes.

# Workers
Workers are the people in your colony. You need them to do jobs and to do anything, really. They're abstracted away as a table, pretty much, at least in the prototype.