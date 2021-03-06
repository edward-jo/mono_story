import 'dart:math';

import 'package:mono_story/constants.dart';
import 'package:sqflite/sqflite.dart';

void createFakeRecordsForTest(Database db) async {
  await db.execute('''
INSERT INTO $threadsTableNameV2 (${ThreadsTableCols.name})
VALUES ('Twitter'),
       ('CNN'),
       ('Instagram'),
       ('์ผ๊ธฐ'),
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

    '''When you wanna do an HTTP request in Android you have to 1. install Retrofit 2. create the service interface 3. instantiate and wire up Retrofit. In JavaScript, you just call fetch(URL, method) and that's it ๐คฏ''',

    '''GoLand is a clever Go IDE with extended support for JavaScript, TypeScript, and databases. Take your projects one step further, whether youโre a newbie or an experienced professional. Start your free 30-day trial today!''',

    '''[DHP ๋์งํธ ํฌ์ค์ผ์ด ์์นด๋ฐ๋ฏธ 2022] ์๊ฐ์ ๋ชจ์ง! https://dhpartners.io/dhpacademy ์ต์ค์ญ, ์ ์งํ, ๊น์น์ ํํธ๋ ๋ฑ ๋์งํธํฌ์ค์ผ์ด ๋ถ์ผ์์ ์ต๊ณ ์ ์ ๋ฌธ๊ฐ 10๋ถ์ ๋ชจ์๊ณ  ๋ฃ๋ ์ฝ์ค์๋๋ค. ๊ด์ฌ ์๋ ๋ถ๋ค์ ๋ฑ๋กํด ๋ณด์ธ์.''',

    '''์๋ง์กด์ด ํ ๋กํค์ ์ ๋ ฅ ์ธ์์๋ก ๋ถ์์ค์ด๋ผ๋ WSJ๋ณด๋ https://wsj.com/articles/peloton-draws-interest-from-potential-suitors-including-amazon-11644012693?mod=djemalertNEWS ๋ํ์ ์ธ ์ฝ๋ก๋ ์ํ์ฃผ์ธ ํ ๋กํค์ ์ฌ๋๋ค์ด ์ง์ฝํ๋ฉฐ ์ด๋ํ๋ฉด์ ์ฃผ๊ฐ๊ฐ ๊ธ์์น. ์์ด์ด ๋ฌด๋ ค 50B๊น์ง ์ฌ๋ผ๊ฐ๋ค๊ฐ ์ง๊ธ์ 8B๊น์ง ๊ธ๋ฝ.''',

    // 5
    '''์๋ง์กด์ ์์ด์ด ํ๋ฃจ์ 191B์ด ์์น. ๋ฏธ๊ตญ๊ธฐ์ ์ญ์ฌ์ ํ๋ฃจ์ ์์ด์ด ์ฆ๊ฐํ ์ต๋์น๋ผ๊ณ . https://wsj.com/articles/amazon-share-price-surges-premarket-following-bumper-earnings-11643975567?mod=djemalertNEWS ๋ฏธ๊ตญ ๊ธฐ์ ์ญ์ฌ์ ์ต๊ณ ๋ก ํ๋ฃจ์ ์์ด์ด ๋ง์ด ๋น ์ง ๋ฉํ์ ๋์กฐ์ ์ธ ๊ธฐ๋ก.''',

    '''๋ฒ๋ ์์ฃผ ๋์น๋ 70์ธ ํ์ฅ๋, ์ง์  ๋ง๋  'ํผํ์ฑ' ๋ดค๋๋โฆ https://news.naver.com/main/read.naver?mode=LPOD&mid=sec&oid=015&aid=0004660087 ์ง๋์  ์ค์นด์ด๋ ์ดํฌ ํ์ฅ์ด ์ง์  ์๋ฒฝ์ ์ฝ๋ฉ๊ณต๋ถํด์ ๋ง๋  ๊ณจํ์ฑ ๋ฒ๋์บ๋. ํผํ์๋ฅผ ์ค์ด๊ณ  ์ถ์ ๋ณธ์ธ์ ๋ฌธ์ ๋ฅผ ํด๊ฒฐํ ํ๋ก์ ํธ. ์ฌ์ฌ๋ฅผ ๋ค์ฌ ์คํํธ์๊น์ง ์ค๋ฆฝ.''',

    '''์ฃผยท์นํจยท๋ผ๋ฉดยท์ค์ง์ด๊ฒ์โฆ์ผ๋ณธ์ โํ๊ตญโ์ด ๋์ณ๋๋ค https://joongang.co.kr/article/25045649 ์ผ๋ณธ ๋๋ค ๋งํธ์์๋ ์ฐธ์ด์ฌ์ ๋ณผ ์ ์๊ณ , ๋ํคํธํ์๋ ํ๊ตญ์ํ์ฝ๋๊ฐ ์๊ฒผ๋ค๊ณ . ์งํํ์ธ ๋๋ฆฌ์นด์ ์์ผ ์  ์์ฌํ์ ๋ฌธ๊ธฐ์์ ์์ฆ ์ผ๋ณธ ๋ถ์๊ธฐ ์๊ฐ.''',

    '''โ๋ทํ๋ฆญ์ค ์ค๋ ํ๋ฃจ 500์์ ๋น๋ฆด ์ ์์๊น์? ๊ฐ๋ฅํ์  ๋ถ ๋๊ธ ์ฃผ์ธ์โ โ๋ทํ๋ฆญ์ค ์ค๋ ์์ ๊น์ง 300์์ ๋น๋ฆฌ๊ณ  ์ถ์ด์!โ https://news.naver.com/main/read.naver?mode=LPOD&mid=sec&oid=023&aid=0003670605 ๊ฒฐ๊ตญ ์ด๋ฌ๋ค๊ฐ ์๊ตฌ๋ ์ ๋ฃ ์ฌ์ฉ์๊ฐ ๋  ๋ฏ.''',

    '''If you plan to bring guests to this space, a private office or conference room booking is required. Please note that the number of guests is limited to the capacity of the room booked''',

    // 10
    '''Today's memo is sponsored by Flatfile: Solve the critical stage of your product onboarding with the platform built to get customers to value, faster. Flatfile enables you to focus on building product features your customers need, not wasting cycles on cleaning spreadsheets. Your product deserves a world-class data import experience.

Iโm always thinking about how to be a better partner to my engineering counterparts and how to distill my learning into a repeatable formula I can adapt to any situation. I remember once kicking off a meeting for a PRD I had just written with a new engineering manager. My goal was to finish the meeting with a timeline and milestones. While we accomplished those things by the end of the meeting, I had a sinking feeling that the meeting didnโt go well, but I couldnโt pinpoint the reason.

I realized the uneasiness came from the tech leadโs confidence that the project would be easy to implement. I didnโt feel like we were able to dig deeper into the risks, but at the same tim''',

    '''Junior engineers tend to describe projects with smaller scope and limited variance in outcome. They usually describe successfully executing a plan rather than including their own judgment and decisions in the outcome.''',

    '''PM: โGreat working with you! I want to be the best PM I can be for you, and I value our partnership. I want to learn about your past projects so I can learn about your working style. Could you tell me about a few things you worked on?โ''',

    '''Apple Developer ID Intermediate Certificate (G2)

The digital certificates you use to sign your software and installer packages on macOS are now issued from a new Developer ID Intermediate Certificate that expires on September 16, 2031. Newly issued Developer ID certificates associated with the new intermediate certificate can be used to sign software on Xcode 11.4.1 and later. If youโre running Xcode 13.2 or later, the updated certificate will download automatically when you sign software after January 28, 2022. If youโre using an earlier version of Xcode, download the certificate manually or create certificates compatible with previous versions of Xcode.''',

    '''ใใ.. ์ ๋ง ์์ฒญ๋ ํ๋๋ผ์ ์์๋ฅผ ์ด์ด๋ฒ๋ฆฐ ๋๋์ธ๋ฐ ์์ ์คํํธ์ ์์น์์ ํ  ์ ์๋๊ฒ ๋ณ๋ก ์๋ค. ๊ทธ๋ฅ ๋ธ๋ก๊ทธ ๊ธ์ด๋ ์ฐ๊ณ  ๋๋ผ๊น..''',

    // 15
    '''์์ด๊ฐ ํ๋ค๋ ๋ฏธ๊ตญ ๊ณ ๋ฑํ๊ต ์ด๋ฐ, ์ ๊ต 2000๋ช ์ค ์ ์ผํ๊ฒ ํ๊ตญ์ด๋ฅผ ํ  ์ ์๋ ์น๊ตฌ์ฌ์ ๋ ์นํด์ง ํ์์ด ใใ ๊ฐ์ด ๊ฒ์๋ ์์ฒญ ํ๊ณ  ์ฑ๋ฐฉ์ ๊ณต๋ถ๋ ๊ฐ์ด ํ๋ฌ ๋ค๋๊ณ .. ์๋ ์ฌ๋ฐ๊ณ  ์ฑ๊ฒฉ์ด ์ข์์ ์ฆ๊ฑฐ์ด ๊ณ ๋ฑํ๊ต ์์ ์ ๋ณด๋ด๋๋ฐ ํฐ ์ญํ ์ ํด์ค ์น๊ตฌ์ด๊ธฐ๋ ํ๋ค. ํนํ ๋ด ๋ํ๊ต ์กธ์๋๋ ํ์์ด๊ฐ ์ง์  ์์ ์ถํํด์ฃผ๊ณ , ๋ด ์์ฌ ์กธ์์ ๋๋ ๋ด ์กธ์์ ์๊ฐ๊ณ  ์ด ์น๊ตฌ ๋ํ ์กธ์์์ ์ฐพ์๊ฐ์ ์ถํํด์คฌ์๋๋ฐ ใใ
์ง๊ธ์ '๋ง์'์ด๋ผ๋ ์ด๋ฆ์ผ๋ก ๋ ์ ๋ชํ (๊ฑฐ์) 100๋ง ๊ตฌ๋์๋ฅผ ๊ฐ์ง ์์ฒญ๋ ์ ํ๋ธ ํฌ๋ฆฌ์์ดํฐ์ธ ๋ด ์น๊ตฌ๊ฐ ์ง์  ์ด๋ ๊ธฐ๊ตฌ๋ฅผ ๊ฐ์ง๊ณ  ์ฐ๋ฆฌ ํ์ฌ์ ๋ฐฉ๋ฌธํด์ ์ฌ๋ฐ๋ ์ปจํ์ธ ๋ ์ฐ์ด์ฃผ๊ณ  ํ๋ณด๋ ํด์คฌ๋ค!!
์ด ์น๊ตฌ๋ ๋๋ ๊ฐ์ ์ฌ์์ ํ๊ณ  ์๋๋ฐ, ๋ชจ๋ ์๋์ฆ์~~~!!โฆ''',

    '''12์๋ถํฐ ์งํ๋ ํฐ์ค๋ฆฌ ์ฐ๊ตฌ์๋ค์ ์ฐ๊ตฌ์์ด ์ข๋ฃ๋์๊ณ , ์ค๋์ ๊ฐ์๊ฐ ์งํํ ์ฐ๊ตฌ๋ค์ ๋ํ ๋ด์ฉ์ ์ฌ๋ด์ ๊ณต์ ํ๋ ์ธ๋ฏธ๋/๋ฐํํ๋ฅผ ์งํํ๊ณ  ์์ต๋๋ค ๐ค
ํฐ์ค๋ฆฌ๋ ์คํ์๋ธ ์ํ๋ฆฌํฐ ๋ถ์ผ์ ๋ฆฌ๋๋ก์จ ๊ณ์ํด์ ์ ๋ํ๊ธฐ ์ํด ๊พธ์คํ ์ฐ๊ตฌํ๊ณ  ํ์๊ฐ์ ๊ธด๋ฐํ ๊ณต์ ํจ์ผ๋ก์จ ๋น ๋ฅด๊ฒ ์ฑ์ฅํด๊ฐ๊ณ  ์์ต๋๋ค.
๊ณต๋ถํ๋ ์๋๋ณด๋ค ๋น ๋ฅด๊ฒ ๊ณต๋ถํ  ๊ฒ์ด ์๋กญ๊ฒ ์๊ธฐ๋ ์์ฆ.. ํฐ์ค๋ฆฌ ํ์ดํ!! ใใ ๐ค''',

    '''์๊น ํด๊ทผํ๊ธฐ ์ ์ ๋ธ๊ท๋ฏผ๋์ด ํฅ๋ฏธ๋ก์ด 'KLEVA ์ฌํ'์ ๋ํด์ ์๋ ค์ฃผ์์ ๋ด์ผ (์๋ ์ค๋..) ์์นจ ํ์๋ถํฐ ๋ฐค๊น์ง ์ผ์ ์ด ์๋๋ฐ๋ ๋ถ๊ตฌํ๊ณ  ์ ์  ๋ชป์ฐจ๋ฆฌ๊ณ  Juno Im์ ํจ๊ป ๋ฐค์ ๋น๋ฐ์ ํํค์ณ๋ดค์ต๋๋ค โ. (๋ด์ฉ ์ ๋ฆฌํ๊ณ  ๊ธ ์ฐ๋๋ฐ ๋ ์๊ฐ ๋ง์ด ์ด๊ฑด ๋น๋ฐ..)
๋ธ๋ก์ฒด์ธ ๋ณด์ ๊ต์์ธ ์ฃผ๋ธ๋ชฌ์คํฐ์ ํจ๊ป klaytnscope๋ฅผ ๋ค์ ธ๊ฐ๋ฉฐ, ๋ฐ์ดํธ์ฝ๋ ๋ถ์ํด๊ฐ๋ฉฐ ์ฝ์ง์ ํ๋๋ฐ์. ๊ฒฐ๊ตญ ๋ฌด์จ ์ผ์ด ์ผ์ด๋ฌ๋์ง, ์ ์ผ์ด๋ฌ๋์ง ์์๋๊ณ  ์ ํฌ๊ฐ ๋ถ์ํ ์ค๋ KLEVA ์ฌํ์ post-mortem์ ๊ฐ๋ตํ๊ฒ ์์ฑํด๋ณด์์ต๋๋ค.
1,700๋ง๋ถ (์ฝ 200์ต์) ๐ธ ๊ท๋ชจ์ ์์ฐ์ด ๋น ์ ธ๋๊ฐ๋ฉด์ ์๋น์ค๋ ์ผ์ ์ค๋จ๋๊ณ  ๋ง์ ์ฌ๋๋ค์ ํจ๋์ผ๋ก ๐ฑ ๋ชฐ์๋ ์ฌ๊ฑด์ ๋ํด์ ๊ถ๊ธํ์  ๋ถ๋ค์ ์๋ ๋ฌธ์๋ฅผ ํ์ธํด์ฃผ์ธ์ ๐''',

    '''๊ตญ๋ฏผ์ํ ์ด์ค์ ๋ํ๋ 6์ผ ๋น๋ด ์ผ๊ฐ์์ ๊ตญ๋ฏผ์๋น ์์ฒ ์ ํ๋ณด์์ ๋จ์ผํ๋ก ์ด ์ ๊ธฐ๋ ๋ฐ ๋ํด โ์ค๋ง ๋ ์ต๋ช์ง์ด๋โ๋ฉฐ โ์ง์ ๋จธ๋ฆฌ๊ฐ ๋๋ ค๊ณ  ํ๋คโ๊ณ  ํ๋ค.

์ด ๋ํ๊ฐ ์ง์ ํ โ์ต๋ช์งโ์ ์ ๋  ํ ์ธ๋ก ์ ์ธํฐ๋ทฐํ ์ต๋ช์ ๊ตญ๋ฏผ์ํ ๋น๋ก๋ํ A ์์์ผ๋ก ํด์๋๋ค.

A ์์์ โ์ด์ค์ ๋ํ ๋ฑ์ด (์ ํ๋ณด์) ๋จ์ผํ์ ์ ์ ๊ทธ์ด์ ๊ณต๊ฐ์ ์ผ๋ก ๋งํ์ง ๋ชปํ  ๋ฟ, ๋ด๋ถ์ ์ผ๋ก๋ ์์ง๋ ๋จ์ผํ ํ์์ฑ์ ๊ณต๊ฐํ๋ ์์์ด ๊ฝค ์๋คโ๋ฉฐ โ์ด์ค์ ๋ํ์ ์ต๊ทผ ์ธํ์ ๊ตญ๋ฏผ์๊ฒ ๋ค์ โ์ค๋งโํ๊ฒ ๋ณด์ผ ์๋ ์๋คโ๋ผ๊ณ  ํ๋ค.

A ์์์ โ์ด๊ธฐ๋ ๊ฒ๋ง์ด ์๋๋ผ ์ด๋ป๊ฒ ์ด๊ธฐ๋๋๋ ๋งค์ฐ ์ค์ํ๋คโ๋ฉฐ โ์ฌ์์ผ๋ ๊ตญ๋ฉด์ ํด๊ฒฐํ๊ธฐ ์ํด์๋ผ๋ ๋จ์ผํ๋ฅผ ํตํด ์ ๊ถ ๊ต์ฒด๋ฅผ ํด๋ด์ผ ํ๋คโ๊ณ ๋ ํ๋ค.

์ง๋ํด ๋ง ์ด๋ฅธ๋ฐ โ์คํต๊ด(์ค์์ด ์ธก ํต์ฌ ๊ด๊ณ์)โ๋ค๊ณผ ์ ๋ฉด ์ถฉ๋ํ๋ ์ด ๋ํ๊ฐ ์ด๋ฒ์ ์ ํ๋ณด์์ ๋จ์ผํ๋ก ์ ์ ๊ธฐํ๋ ์ต๋ช ๊ด๊ณ์๋ฅผ ๋น๋ํ๊ธฐ ์์ํ ๊ฒ์ด๋ค.

์ด ๋ํ๋ ์ง๋ํด ๋ง ์ ํ๋ณด์์ ๋จ์ผํ โ๊ฑฐ๊ฐ๊พผโ ๋ธ๋ฆ์ ํ๋ ์ฌ๋์ โํด๋นํ์์โ๋ก ๊ฐ์ฃผํ๊ณ  ์ง๊ณํ๊ฒ ๋ค๊ณ  ์ ์ธํ๋ค. ์ดํ ๊ตญ๋ฏผ์ํ ์ค์์ด ํ๋ณด์ ๋จ๋ ๋น์  ๊ฐ๋ฅ์ฑ์ ์ฃผ์ฅํ๋ฉฐ ์ฐ์ผ ์์ฒ ์ ํ๋ณด ์ธก๊ณผ ๋ ์  ๊ณต๋ฐฉ์ ์ด์ด๊ฐ๊ณ  ์๋ค.

๊ทธ๋ฌ๋ ๊ตญ๋ฏผ์ํ ๋ด์์๋ ์ต๊ทผ โ๋ค์ฅ๋ ์ฅํ ์ฌ๋ก ์กฐ์ฌ ์ง์ง์จ๋ง ๋ฏฟ๊ณ  ์๊ฐ๋ก ์ ํผ์น  ๋งํผ ์ฌ์ ๋ก์ด ๋์ ์ด ์๋๋คโ(์ค์ํ ์์) ๊ฐ์ ๋จ์ผํ ๊ณต๊ฐ ์ ์๊ฐ ๋์ค๊ณ  ์๋ค.''',

    '''์์์ ์ ํฅ๊ตญ์ด์ ์์ถ ์์กด๋๊ฐ ๋์ ์๊ท๋ชจ ๊ฐ๋ฐฉ๊ฒฝ์  ์ฒด์ ๋ผ๋ ์ ์์ โ๋ฎ์๊ผด ๊ตญ๊ฐโ๋ก ๋ถ๋ฆฌ๋ ํ๊ตญ๊ณผ ๋๋ง์ ์ฃผ์์์ฅ์ด ์๋ ํ๋ฐ๊ธฐ ์ดํ ์๋ฐ๋ ํ๋ฆ์ ๋ณด์ด๊ณ  ์๋ค. ๋๋ง ๊ฐ๊ถ์ง์๋ ์ต๊ทผ ๋ฏธ๊ตญ์ ํตํ ๊ธด์ถ ์ฐ๋ ค์ ๋ฌ์์ยท์ฐํฌ๋ผ์ด๋ ๋ถ์ ์์์ ์ํญ ํ๋ฝํ๊ธด ํ์ผ๋ ์๋ 4๋ถ๊ธฐ ์ด๋ 6.7% ์์น(1๋ง6570.89โ1๋ง7674.40)ํ๋ค.(๋๋ง ์ฆ์๋ ์ถ์  ์ฐํด๋ก 2์ 7์ผ ์ฌ ๊ฐ์ฅ ์์ ) ๋ฐ๋ฉด ํ๊ตญ ์ฝ์คํผ ์ง์๋ ๊ฐ์ ๊ธฐ๊ฐ 15.5%๋ ํ๋ฝ(3207.02โ2709.24)ํ๋ค.

๊ตญ๋ด์ด์์ฐ(GDP) ๋๋น ์์ถ ๋น์ค์ด 60~70%์ ๋ฌํ๋ ๋ ๋๋ผ๋ ์์ถ ๊ฒฝ๊ธฐ๊ฐ ๊ฒฝ์ ์ ๋ฏธ์น๋ ์ํฅ์ด ์ ๋์ ์ด๋ค. ์๋ 4๋ถ๊ธฐ ํ๊ตญ์ ์์ถ ์ฆ๊ฐ์จ(25%)์ด ๋๋ง(26%) ๋ชป์ง ์๊ฒ ๋์ ์์ค์ ๊ธฐ๋กํ์์๋ ์ฃผ์์์ฅ์ ์จ๋ ์ฐจ๊ฐ ์ปธ๋ ์ด์ ๋ ๋ญ๊น. ์ ๋ฌธ๊ฐ๋ค์ ํ๊ตญ๊ณผ ๋๋ง ์ฆ์์ ๋์ปคํ๋ง(decouplingยท๋น๋์กฐํ)์ด ์ฌํ๋๋ ์์ธ์ผ๋ก โฒ๋ฏธยท์ค ๊ฐ๋ฑ์ ๋ฐ๋ฅธ ๋ฐ์ฌ ์ด์ต ์ฐจ์ด โฒ์ฐ์ ๊ตฌ์กฐ ์ฐจ์ด์ ๋ฐ๋ฅธ ๋ฌด์ญ์์ง ๊ฒฉ์ฐจ โฒ์์ถ ๋ฌผ๋ ๋ฐ ๋จ๊ฐ์ ์ฆ๊ฐ์จ ์ฐจ์ด โฒ๋๋จ์ ์ง์ญ ๊ณต๊ธ๋ง ๋ถ๊ดด ์ฌํ ๋ฑ ํฌ๊ฒ ๋ค ๊ฐ์ง๋ฅผ ๋ค๊ณ  ์๋ค.''',

    // 20
    '''์ค๊ตญ ํ์ง ๋ณด์์์์ด 2022 ๋ฒ ์ด์ง ๋๊ณ์ฌ๋ฆผํฝ ๊ฐ๋ง์์ ๋ณด๋ํ๋ ์ธ์ ๊ธฐ์๋ฅผ ๋๋ท์์ด ๋์ด๋ด ๋ผ๋์ด๋ค. ๋น์ ์ํฉ์ ์๋ฐฉ์ก ๋ด์ค ํ๋ฉด์ ํตํด ์ ํ๋ฅผ ํ๊ณ  ๊ฒฐ๊ตญ ์ทจ์ฌ์ง์ ํ์ฅ ์์ค๊ณ๋ฅผ ์ค๋จํด์ผ ํ๋ค.

๋ฌธ์ ์ ์ฅ๋ฉด์ 4์ผ ๋ค๋๋๋ ๊ณต์ ๋ฐฉ์ก์ฌ NOS ๋ด์ค ๋์ค ๋ฑ์ฅํ๋ค. ์คํ๊ถ ํนํ์ ์คํธ์ด๋ ๋ด ๋ค์ค๋ ๋ฒ ์ด์ง ์ฌ๋ฆผํฝ ๊ฐ๋ง์์ด ์งํ๋ ๋ฒ ์ด์ง ๊ตญ๊ฐ์ฒด์ก์ฅ ๋ฐ์์ ๋ง์ดํฌ๋ฅผ ๋ค์๊ณ , ์ต์ปค์ ์ง๋ฌธ์ ๋ฐ์ ๋ค ํ์ฅ ๋ถ์๊ธฐ๋ฅผ ์ ํ๊ธฐ ์์ํ๋ค.

๊ทธ๋ฌ๋ ๊ทธ๊ฐ ์์ ๋ผ์๋ง์ ๋ถ์ ์์ฅ์ ํ์ ์ฐฌ ์๋ฌธ์ ๋จ์ฑ์ด ์นด๋ฉ๋ผ ์์ผ๋ก ๋์ํ๋ค. ๋จ์ฑ์ ์ค๊ตญ์ด๋ก ์๋ฆฌ๋ฅผ ์ง๋ฅด๋ฉฐ ์คํธ์ด๋์ ์ํ์ ๋ถ์ก์๊ณ  ํ์ ์ค ๋์ด๋ด๋ ๋ฏํ ์์ธ๋ฅผ ์ทจํ๋ค. ๋ ํ์ชฝ ์์ผ๋ก ์ด๋๊ฐ๋ฅผ ๊ฐ๋ฆฌํค๋ฉฐ โ์ ์ชฝ์ผ๋ก ๊ฐ๋ผโ๋ ์ ์ค์ฒ๋ฅผ ๋ณด์ด๊ธฐ๋ ํ๋ค.'''
  ];

  final baseDateTime = DateTime.parse('2022-01-01T01:00:00.000Z');
  final random = Random();

  for (int i = 0; i < 50; i++) {
    await db.execute('''
INSERT INTO $storiesTableNameV2 (${StoriesTableCols.story}, ${StoriesTableCols.fkThreadId}, ${StoriesTableCols.createdTime}, ${StoriesTableCols.starred})
VALUES ("( $i ) ${fakeMessages[random.nextInt(21)]}", ${random.nextInt(10) + 1}, "${baseDateTime.add(Duration(days: random.nextInt(40), seconds: random.nextInt(24 * 60 * 60))).toIso8601String()}", ${random.nextInt(2)});
''');
  }
}
