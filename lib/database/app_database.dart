import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mono_story/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Database get database => _database!;

  Future init() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
    await _openAppDatabase();
  }

  Future<void> _openAppDatabase() async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, appDatabaseFileName);

    developer.log('Open database( $databaseFilePath )');
    _database = await openDatabase(
      databaseFilePath,
      version: appDatabaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
    developer.log('Opened database, status(${_database?.isOpen})');
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    // Create thread names table
    await db.execute('''
CREATE TABLE $threadsTableName (
  ${ThreadsTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ThreadsTableCols.name} TEXT NOT NULL
)
 ''');

    // Create messages table
    await db.execute('''
CREATE TABLE $messagesTableName (
  ${MessagesTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${MessagesTableCols.message} TEXT NOT NULL,
  ${MessagesTableCols.fkThreadId} INTEGER,
  ${MessagesTableCols.createdTime} TEXT NOT NULL,
  ${MessagesTableCols.starred} INTEGER NOT NULL,
  FOREIGN KEY(${MessagesTableCols.fkThreadId})
  REFERENCES $threadsTableName (_id)
  ON DELETE SET NULL
)
''');

    if (kDebugMode || kReleaseMode) {
      await db.execute('''
INSERT INTO $threadsTableName (${ThreadsTableCols.name})
VALUES ('Twitter'),
       ('CNN'),
       ('Instagram'),
       ('일기'),
       ('Length30 Very Long Long Thread'),
       ('LinkedIn'),
       ('Stack Overflow'),
       ('Gmail'),
       ('Medium'),
       ('Flutter');
''');

      final List<String> fakeMessages = [
        // 0
        '''While asserts can technically be used to manually create an 'is debug mode' variable, you should avoid that.
Instead, use the constant kReleaseMode from package:flutter/foundation.dart
The difference is all about tree shaking
Tree shaking (aka the compiler removing unused code) depends on variables being constants.
The issue is, with asserts our isInReleaseMode boolean is not a constant. So when shipping our app, both the dev and release code are included.
On the other hand, kReleaseMode is a constant. Therefore the compiler is correctly able to remove unused code, and we can safely do:''',

        '''When you wanna do an HTTP request in Android you have to 1. install Retrofit 2. create the service interface 3. instantiate and wire up Retrofit. In JavaScript, you just call fetch(URL, method) and that's it 🤯''',

        '''GoLand is a clever Go IDE with extended support for JavaScript, TypeScript, and databases. Take your projects one step further, whether you’re a newbie or an experienced professional. Start your free 30-day trial today!''',

        '''[DHP 디지털 헬스케어 아카데미 2022] 수강생 모집! https://dhpartners.io/dhpacademy 최윤섭, 정지훈, 김치원 파트너 등 디지털헬스케어 분야에서 최고의 전문가 10분을 모시고 듣는 코스입니다. 관심 있는 분들은 등록해 보세요.''',

        '''아마존이 펠로톤의 유력 인수자로 부상중이라는 WSJ보도 https://wsj.com/articles/peloton-draws-interest-from-potential-suitors-including-amazon-11644012693?mod=djemalertNEWS 대표적인 코로나 수혜주인 펠로톤은 사람들이 집콕하며 운동하면서 주가가 급상승. 시총이 무려 50B까지 올라갔다가 지금은 8B까지 급락.''',

        // 5
        '''아마존의 시총이 하루에 191B이 상승. 미국기업 역사상 하루에 시총이 증가한 최대치라고. https://wsj.com/articles/amazon-share-price-surges-premarket-following-bumper-earnings-11643975567?mod=djemalertNEWS 미국 기업 역사상 최고로 하루에 시총이 많이 빠진 메타와 대조적인 기록.''',

        '''버디 자주 놓치던 70세 회장님, 직접 만든 '퍼팅앱' 봤더니… https://news.naver.com/main/read.naver?mode=LPOD&mid=sec&oid=015&aid=0004660087 진대제 스카이레이크 회장이 직접 새벽에 코딩공부해서 만든 골프앱 버디캐디. 퍼팅수를 줄이고 싶은 본인의 문제를 해결한 프로젝트. 사재를 들여 스타트업까지 설립.''',

        '''주·치킨·라면·오징어게임…일본에 ‘한국’이 넘쳐난다 https://joongang.co.kr/article/25045649 일본 동네 마트에서도 참이슬을 볼 수 있고, 돈키호테에도 한국식품코너가 생겼다고. 지한파인 나리카와 아야 전 아사히신문기자의 요즘 일본 분위기 소개.''',

        '''“넷플릭스 오늘 하루 500원에 빌릴 수 있을까요? 가능하신 분 댓글 주세요” “넷플릭스 오늘 자정까지 300원에 빌리고 싶어요!” https://news.naver.com/main/read.naver?mode=LPOD&mid=sec&oid=023&aid=0003670605 결국 이러다가 월구독 유료 사용자가 될 듯.''',

        '''If you plan to bring guests to this space, a private office or conference room booking is required. Please note that the number of guests is limited to the capacity of the room booked''',

        // 10
        '''Today's memo is sponsored by Flatfile: Solve the critical stage of your product onboarding with the platform built to get customers to value, faster. Flatfile enables you to focus on building product features your customers need, not wasting cycles on cleaning spreadsheets. Your product deserves a world-class data import experience.

I’m always thinking about how to be a better partner to my engineering counterparts and how to distill my learning into a repeatable formula I can adapt to any situation. I remember once kicking off a meeting for a PRD I had just written with a new engineering manager. My goal was to finish the meeting with a timeline and milestones. While we accomplished those things by the end of the meeting, I had a sinking feeling that the meeting didn’t go well, but I couldn’t pinpoint the reason.

I realized the uneasiness came from the tech lead’s confidence that the project would be easy to implement. I didn’t feel like we were able to dig deeper into the risks, but at the same tim''',

        '''Junior engineers tend to describe projects with smaller scope and limited variance in outcome. They usually describe successfully executing a plan rather than including their own judgment and decisions in the outcome.''',

        '''PM: “Great working with you! I want to be the best PM I can be for you, and I value our partnership. I want to learn about your past projects so I can learn about your working style. Could you tell me about a few things you worked on?”''',

        '''Apple Developer ID Intermediate Certificate (G2)

The digital certificates you use to sign your software and installer packages on macOS are now issued from a new Developer ID Intermediate Certificate that expires on September 16, 2031. Newly issued Developer ID certificates associated with the new intermediate certificate can be used to sign software on Xcode 11.4.1 and later. If you’re running Xcode 13.2 or later, the updated certificate will download automatically when you sign software after January 28, 2022. If you’re using an earlier version of Xcode, download the certificate manually or create certificates compatible with previous versions of Xcode.''',

        '''ㅋㅋ.. 정말 엄청난 판도라의 상자를 열어버린 느낌인데 작은 스타트업 위치에서 할 수 있는게 별로 없다. 그냥 블로그 글이나 쓰고 끝낼까..''',

        // 15
        '''영어가 힘들던 미국 고등학교 초반, 전교 2000명 중 유일하게 한국어를 할 수 있는 친구여서 더 친해진 태양이 ㅋㅋ 같이 게임도 엄청 했고 책방에 공부도 같이 하러 다니고.. 워낙 재밌고 성격이 좋아서 즐거운 고등학교 시절을 보내는데 큰 역할을 해준 친구이기도 하다. 특히 내 대학교 졸업때도 태양이가 직접 와서 축하해주고, 내 석사 졸업식 때는 내 졸업식 안가고 이 친구 대학 졸업식에 찾아가서 축하해줬었는데 ㅎㅎ
지금은 '말왕'이라는 이름으로 더 유명한 (거의) 100만 구독자를 가진 엄청난 유튜브 크리에이터인 내 친구가 직접 운동 기구를 가지고 우리 회사에 방문해서 재밌는 컨텐츠도 찍어주고 홍보도 해줬다!!
이 친구도 나도 각자 사업을 하고 있는데, 모두 잘되즈아~~~!!…''',

        '''12월부터 진행된 티오리 연구원들의 연구월이 종료되었고, 오늘은 각자가 진행한 연구들에 대한 내용을 사내에 공유하는 세미나/발표회를 진행하고 있습니다 🤓
티오리는 오펜시브 시큐리티 분야의 리더로써 계속해서 선도하기 위해 꾸준히 연구하고 팀원간에 긴밀히 공유함으로써 빠르게 성장해가고 있습니다.
공부하는 속도보다 빠르게 공부할 것이 새롭게 생기는 요즘.. 티오리 화이팅!! ㅋㅋ 🤟''',

        '''아까 퇴근하기 전에 노규민님이 흥미로운 'KLEVA 사태'에 대해서 알려주셔서 내일 (아니 오늘..) 아침 회의부터 밤까지 일정이 있는데도 불구하고 정신 못차리고 Juno Im와 함께 밤새 비밀을 파헤쳐봤습니다 ⛏. (내용 정리하고 글 쓰는데 더 시간 많이 쓴건 비밀..)
블록체인 보안 굇수인 주노몬스터와 함께 klaytnscope를 뒤져가며, 바이트코드 분석해가며 삽질을 했는데요. 결국 무슨 일이 일어났는지, 왜 일어났는지 알아냈고 저희가 분석한 오늘 KLEVA 사태의 post-mortem을 간략하게 작성해보았습니다.
1,700만불 (약 200억원) 💸 규모의 자산이 빠져나가면서 서비스는 일시 중단되고 많은 사람들을 패닉으로 😱 몰았던 사건에 대해서 궁금하신 분들은 아래 문서를 확인해주세요 🙂''',

        '''국민의힘 이준석 대표는 6일 당내 일각에서 국민의당 안철수 후보와의 단일화론이 제기된 데 대해 “설마 또 익명질이냐”며 “진절머리가 나려고 한다”고 했다.

이 대표가 지적한 ‘익명질’은 전날 한 언론에 인터뷰한 익명의 국민의힘 비례대표 A 의원으로 해석됐다.

A 의원은 “이준석 대표 등이 (안 후보와) 단일화에 선을 그어서 공개적으로 말하지 못할 뿐, 내부적으로는 아직도 단일화 필요성에 공감하는 의원이 꽤 있다”며 “이준석 대표의 최근 언행은 국민에게 다소 ‘오만’하게 보일 수도 있다”라고 했다.

A 의원은 “이기는 것만이 아니라 어떻게 이기느냐도 매우 중요하다”며 “여소야대 국면을 해결하기 위해서라도 단일화를 통해 정권 교체를 해내야 한다”고도 했다.

지난해 말 이른바 ‘윤핵관(윤석열 측 핵심 관계자)’들과 정면 충돌했던 이 대표가 이번엔 안 후보와의 단일화론을 제기하는 익명 관계자를 비난하기 시작한 것이다.

이 대표는 지난해 말 안 후보와의 단일화 ‘거간꾼’ 노릇을 하는 사람은 ‘해당행위자’로 간주하고 징계하겠다고 선언했다. 이후 국민의힘 윤석열 후보의 단독 당선 가능성을 주장하며 연일 안철수 후보 측과 날선 공방을 이어가고 있다.

그러나 국민의힘 내에서도 최근 “들쑥날쑥한 여론조사 지지율만 믿고 자강론을 펼칠 만큼 여유로운 대선이 아니다”(윤상현 의원) 같은 단일화 공개 제의가 나오고 있다.''',

        '''아시아 신흥국이자 수출 의존도가 높은 소규모 개방경제 체제라는 점에서 ‘닮은꼴 국가’로 불리는 한국과 대만의 주식시장이 작년 하반기 이후 상반된 흐름을 보이고 있다. 대만 가권지수는 최근 미국의 통화 긴축 우려와 러시아·우크라이나 분쟁 소식에 소폭 하락하긴 했으나 작년 4분기 이래 6.7% 상승(1만6570.89→1만7674.40)했다.(대만 증시는 춘제 연휴로 2월 7일 재 개장 예정) 반면 한국 코스피 지수는 같은 기간 15.5%나 하락(3207.02→2709.24)했다.

국내총생산(GDP) 대비 수출 비중이 60~70%에 달하는 두 나라는 수출 경기가 경제에 미치는 영향이 절대적이다. 작년 4분기 한국의 수출 증가율(25%)이 대만(26%) 못지 않게 높은 수준을 기록했음에도 주식시장의 온도 차가 컸던 이유는 뭘까. 전문가들은 한국과 대만 증시의 디커플링(decoupling·비동조화)이 심화되는 원인으로 ▲미·중 갈등에 따른 반사 이익 차이 ▲산업 구조 차이에 따른 무역수지 격차 ▲수출 물량 및 단가의 증가율 차이 ▲동남아 지역 공급망 붕괴 여파 등 크게 네 가지를 들고 있다.''',

        // 20
        '''중국 현지 보안요원이 2022 베이징 동계올림픽 개막식을 보도하던 외신기자를 느닷없이 끌어내 논란이다. 당시 상황은 생방송 뉴스 화면을 통해 전파를 탔고 결국 취재진은 현장 생중계를 중단해야 했다.

문제의 장면은 4일 네덜란드 공영 방송사 NOS 뉴스 도중 등장했다. 중화권 특파원 스호어드 덴 다스는 베이징 올림픽 개막식이 진행된 베이징 국가체육장 밖에서 마이크를 들었고, 앵커의 질문을 받은 뒤 현장 분위기를 전하기 시작했다.

그러나 그가 입을 떼자마자 붉은 완장을 팔에 찬 의문의 남성이 카메라 앞으로 난입했다. 남성은 중국어로 소리를 지르며 스호어드의 양팔을 붙잡았고 힘을 줘 끌어내는 듯한 자세를 취했다. 또 한쪽 손으로 어딘가를 가리키며 ‘저쪽으로 가라’는 제스처를 보이기도 했다.'''
      ];

      final baseDateTime = DateTime.parse('2022-01-01T01:00:00.000Z');
      final random = Random();

      for (int i = 0; i < 100; i++) {
        await db.execute('''
INSERT INTO $messagesTableName (${MessagesTableCols.message}, ${MessagesTableCols.fkThreadId}, ${MessagesTableCols.createdTime}, ${MessagesTableCols.starred})
VALUES ("( $i ) ${fakeMessages[random.nextInt(21)]}", ${random.nextInt(10) + 1}, "${baseDateTime.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", ${random.nextInt(2)});
''');
      }
    }
  }

  Future<void> closeAppDatabase() async {
    if (_database == null || _database!.isOpen == false) {
      return;
    }

    await _database?.close();
    _database = null;
    developer.log('Closed database');
  }

  Future<void> deleteAppDatabase() async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, appDatabaseFileName);

    developer.log('Delete database( $databaseFilePath )');
    await deleteDatabase(databaseFilePath);
    _database = null;
    developer.log('Deleted database');
    return;
  }
}
