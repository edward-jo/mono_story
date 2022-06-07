import 'dart:math';

import 'package:mono_story/constants.dart';
import 'package:sqflite/sqflite.dart';

void createFakeRecordsForAppStore(Database db) async {
  await db.execute('''
INSERT INTO $threadsTableNameV2 (${ThreadsTableCols.name})
VALUES ('Books 📕'),
       ('Travel 🏝'),
       ('The Peanuts'),
       ('Contemplation');
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
("Since travelling allows you to be open-minded, it is easier to accept all situations naturally, and makes you think not to waste time and enjoy youth since time and youth cannot be bought with money.

Travelling not only makes your world bigger but also makes you generous helping you to be more objective rather than emotional which ultimately makes you not to be fluctuated easily between hopes and fear.", 2, "${base20210601.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),


("What makes a good writer? and a good article? It is a very difficult question. Words are always mystery itself. Article that has a huge argument or thoughts that is beyond imagination. There are even super-natural stories that transcends time and space. Stories that make you feel unusual emotions, and reach your imagination's boundary.

We are definitely touched endlessly by those stories.", 4, "${base20210401.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 0),


("I already miss Switzerland although I am in Switzerland.", 2, "${base20210215.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 0),

("Learn from yesterday, live for today, look to tomorrow, rest this afternoon.", 3, "${base20211001.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 0),
("Every time you find some humour in a difficult situation, you win.", 3, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("In the book of life, the answers aren't in the back.", 3, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),

("France reminds us of many things including Art and Romance, but food culture out of all is very advanced. French cuisine including bread, cheese, dessert, escargot has been loved worldwide for centuries, and open mind is needed to enjoy and experience diverse food culture. No Hesitation, but brave new tryouts will lead to world's best cuisines that is yet to be revealed.", 2, "${base20200601.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("Namaste means 'My god inside me respects the one inside you'. It is a greeting of harmony that implies god is inside everything including you and myself and I respect it.", 2, "${base20200601.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),


("Article that is extremely ordinary, simple without any fancy words where one word will lead to another, article that makes readers comfortable.
That is the kind of article I want to write.", 4, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("We are all born with creativity, but we lose its power and talent due to logics and society put into our head.", 4, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),
("Sunsets never get old.", 4, "${base20210101.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1),

("The Midnight Library by Matt Haig

Nora took a journey to many different lives and found a life that she truly wanted at the end of her journey. She wanted to live as a rain, and found that what you see is not important, but the perspective. Nora came back from the verge of death. It is easy to feel the lack for the life that you cannot live. What if I have worked harder, what if I have invested thoroughly, what if I was popular...

It is not difficult to see through other's eyes and wish for optimum you that others want, but we need to realize that our lives are in progress and are very beautiful that is worth living.

So we need to cherish our life that we live in and progress forward positively.", 1, "${base20190201.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", 1);
''');
}
