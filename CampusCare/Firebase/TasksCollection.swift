

import FirebaseFirestore

final class TasksCollection{
   
    // Reference to your Firestore collection
     private let tasksCollectionRef = FirestoreManager.shared.db.collection("Tasks")
     
     // Fetch tasks for a specific date
     func fetchTasks(for date: String, completion: @escaping ([Task]) -> Void) {
         tasksCollectionRef
             .whereField("assignedDate", isEqualTo: date)
             .getDocuments { snapshot, error in
                 var tasks: [Task] = []
                 
                 if let error = error {
                     print("Error fetching tasks: \(error.localizedDescription)")
                     completion(tasks) // return empty array on error
                     return
                 }
                 
                 if snapshot?.documents.isEmpty == true {
                     print("No tasks found for date: \(date)")
                 }
                 
                 snapshot?.documents.forEach { document in
                     let data = document.data()
                     let task = Task(
                         id: document.documentID,
                         requestId: data["requestId"] as? String ?? "",
                         assignedDate: data["assignedDate"] as? String ?? "",
                         status: data["status"] as? String ?? ""
                     )
                     tasks.append(task)
                 }
                 
                 completion(tasks)
             }
     }
}
