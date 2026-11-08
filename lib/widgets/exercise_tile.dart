import 'package:flutter/material.dart';
class ExerciseTile extends StatelessWidget {
  final icon;
  final String exerciseName;
  final int numberOfExercises;
  final color;


  const ExerciseTile({
   Key? key,
    required this.icon,
    required this.exerciseName,
    required this.numberOfExercises,
    required this.color,
  }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return /// ListView of Exercises
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(

          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: color,
                      child: Icon(icon, color: Colors.white,),
                    ),
                  ),

                  SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        numberOfExercises.toString() + ' Exercises',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.more_horiz),
            ],
          ),
        ),
      );
  }
}
