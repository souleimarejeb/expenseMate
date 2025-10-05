class Film {
   int? id;
   String? title;
   String? image;

   Film({this.title, this.image,this.id});

   // Convert Task to Map for database operations
   Map<String, dynamic> toMap() {
     return {
       'id': id,
       'title': title,
       'image': image,
     };
   }
// from map to an object
   factory Film.fromMap(Map<String, dynamic> map) {
     return Film(
       id: map['id'],
       title: map['title'],
       image: map['image'],
     );
  }
  @override
  String toString() {
    return 'Film{id: $id, title: $title, image: $image}';
  }

}