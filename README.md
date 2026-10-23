IT 126 – Module 3 Lesson 2: In-Memory Task Manager
Description
This is the first activity version of the Task Manager. It uses a simple Flutter text field, an Add Task button, and a list to show tasks. Tasks are stored only in a Dart list in memory.
Expected result
Tasks appear while the app is running. If the app process ends and the app is relaunched, the tasks are gone because this version does not use persistent storage.
Analysis
1. What happened to the task titles when you added them to the list?
The task titles were added to the list and displayed on the screen.
2. Why could the application display the tasks while it was running?
The tasks were stored in a Dart list in memory while the app was running.
3. What happened after the application process ended and the application was relaunched?
The tasks were gone because they were stored only in memory.
4. Would keeping the list inside a StatefulWidget automatically make the tasks persistent? Explain your answer.
No. StatefulWidget keeps data while the app is running, but it does not permanently save the data.
5. What would the application need to do to preserve the tasks between sessions?
It would need to save the tasks using persistent storage, such as SQLite.
6. If the application eventually stored hundreds or thousands of tasks, what problems might arise from managing all the data manually in memory?
It could become difficult to search, update, organize, and manage many tasks. The tasks would also be lost when the app closes.
7. How could separating the operations that save and retrieve tasks from the UI make the application easier to maintain?
It keeps the UI code separate from the data operations, making the app easier to understand and change.