import 'dart:developer' as developer;
import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mono_story/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void createFakeRecordsForAppStore(Database db) async {
  await db.execute('''
INSERT INTO $threadsTableNameV2 (${ThreadsTableCols.name})
VALUES ('Books 📕'),
       ('Travel 🏝'),
       ('Suits 🤵‍♂️'),
       ('Reflective');
''');

  final base20211001 = DateTime.parse('2021-10-01T01:00:00.000Z');
  final base20210601 = DateTime.parse('2021-06-01T01:00:00.000Z');
  final base20210401 = DateTime.parse('2021-04-01T01:00:00.000Z');
  final base20210215 = DateTime.parse('2021-02-15T01:00:00.000Z');
  final base20210101 = DateTime.parse('2021-01-01T01:00:00.000Z');
  final base20200601 = DateTime.parse('2020-06-01T01:00:00.000Z');
  final base20190201 = DateTime.parse('2019-02-01T01:00:00.000Z');
  final random = Random();
  await db.execute('''
INSERT INTO $storiesTableNameV2 (${StoriesTableCols.story}, ${StoriesTableCols.fkThreadId}, ${StoriesTableCols.createdTime}, ${StoriesTableCols.starred})
VALUES
("You're weird. We'll be friends.", 3, "${base20211001.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 0),


("Banff is one of the most beautiful national parks in Canada. It boasts breathtaking mountain scenery, epic hiking trails, and picturesque camping grounds and lodges.", 2, "${base20210601.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("My eyes are getting heavier tonight. I should sleep soon. It’s funny how I always think I have nothing to say but once I play with the start of ideas, it all starts to come down like rain.

I needed this. To know I still have it in me. If I were to ever lose this part of myself… I’m not sure how I’d take that.

For sure, I would feel so sad and so alone. Lost even.

Writing is another love of mine. Writing is a form of looking in the mirror. Like drawing a figure. It is the drawing of one’s soul. Of one’s subconscious.

Perhaps if you write the cusp of one’s soul and draw it out like a thread from the tangle of nothingness. And perhaps soon – it can become poetry.", 4, "${base20210401.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 0),
("In Vancouver, it’s best to stay in the heart of it all. All the prime spots are downtown, and staying there will keep you in the center of everything. The Yaletown, Gastown, and Robson areas are the best of the best downtown.", 2, "${base20210215.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 0),


("How do you live? - Genzaburo Yoshino -

This one’s a beautiful coming of age story that’s full of charm. It centres around friendship, science, and humanity. We get a glimpse of the wholesome relationship between a boy and his wise uncle, who writes him invaluable advice about life through letters. Oh, and world-renowned director Hayao Miyazaki has also announced that he will be adapting this novel into a film!!! I cannot wait to see what Miyazaki has in store for us. The books is truly delightful, and so wholesome. I highly recommend it if you feel lost and need a gentle, yet impactful pick-me-up (and perhaps a sprinkle of uncle’s magic and wits)! ❤", 1, "${base20210215.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),


("Let them hate, just make sure they spell your name right.", 3, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("I don’t have dreams, I have goals.", 3, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("I'm a boy scout. I like to be prepared.", 3, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("Anyone can do my job, but no one can be me.", 3, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),


("While there are some first-class restaurants in Vancouver, the tasty grub from the local food trucks is some of the best food in town. Juice Truck, Aussie Pie Guy, Community Pizzeria, Mom’s Grilled Cheese Truck.", 2, "${base20200601.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("Kitsilano Beach

This place is hopping during the summer, and even during the colder months, it’s a great stop for gorgeous photo ops.", 2, "${base20200601.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("Lynn Canyon Park

Another beautiful place to reconnect with nature, Lynn Canyon Park was made for long afternoons out hiking, and of course, you have to make it over to the Lynn Canyon Suspension Bridge.", 2, "${base20200601.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),


("Born A Crime by Trevor Noah
One of my favorite audiobooks ever. Love, love, love every second of it. The narrator is the author himself, and he did such an AMAZING job bringing his own story to life. I love the way he explored apartheid, his childhood, and his pathway to becoming the person that he is today through a tone that is hilarious, witty, impactful, and sad all at the same time. You learn so much, and there is not a dull moment in this book. This is the perfect book for if you’re in a slump (or not.. it’s the perfect book to pick up anytime really!). It’s memorable, brilliant, and entertaining. Love it.", 1, "${base20190201.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1);
''');
}
