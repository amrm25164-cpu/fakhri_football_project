import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FakhriFootballApp());

const green = Color(0xFF35D07F);
const bg = Color(0xFF0B1117);
const panel = Color(0xFF151F28);

class FakhriFootballApp extends StatelessWidget {
  const FakhriFootballApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fakhri Football',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.dark),
      useMaterial3: true,
      cardTheme: const CardThemeData(color: panel, margin: EdgeInsets.zero),
      appBarTheme: const AppBarTheme(backgroundColor: bg, centerTitle: false),
    ),
    home: const MainShell(),
  );
}

class MatchItem {
  final String home, away, competition, time, status, score;
  MatchItem(this.home, this.away, this.competition, this.time, this.status, this.score);
  factory MatchItem.fromJson(Map<String,dynamic> j) => MatchItem(
    '${j['home'] ?? j['homeTeam']?['name'] ?? 'Home'}',
    '${j['away'] ?? j['awayTeam']?['name'] ?? 'Away'}',
    '${j['competition'] ?? j['league']?['name'] ?? 'Football'}',
    '${j['time'] ?? j['utcDate'] ?? ''}',
    '${j['status'] ?? 'Scheduled'}',
    '${j['score'] ?? '${j['score']?['fullTime']?['home'] ?? '-'} : ${j['score']?['fullTime']?['away'] ?? '-'}'}',
  );
}

class FootballApi {
  // Add your provider's endpoint and key in Settings. Providers use different schemas.
  static Future<List<MatchItem>> fetchMatches(String endpoint, String apiKey) async {
    if (endpoint.trim().isEmpty || apiKey.trim().isEmpty) {
      throw Exception('أضف رابط API ومفتاحه من الإعدادات لعرض بيانات حقيقية.');
    }
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme) throw Exception('رابط API غير صالح.');
    final response = await http.get(uri, headers: {
      'X-Auth-Token': apiKey,
      'x-apisports-key': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('فشل الاتصال بمصدر البيانات (${response.statusCode}). راجع الرابط والمفتاح.');
    }
    final decoded = jsonDecode(response.body);
    final List<dynamic>? rows = decoded is List ? decoded :
      decoded is Map ? (decoded['matches'] as List?) ??
        (decoded['response'] as List?) ?? (decoded['data'] as List?) : null;
    if (rows == null) throw Exception('صيغة الرد غير معروفة. يلزم تكييف المحول مع مزود API.');
    return rows.whereType<Map<String,dynamic>>().map(MatchItem.fromJson).toList();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [HomePage(), MatchesPage(), LeaguesPage(), AnalyticsPage(), MorePage()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: index, children: pages)),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) => setState(() => index = i),
      backgroundColor: panel,
      indicatorColor: green.withOpacity(.18),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'المباريات'),
        NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'الدوريات'),
        NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'التحليلات'),
        NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'المزيد'),
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(children: [
        Container(width: 46,height: 46,decoration: BoxDecoration(color: green,borderRadius: BorderRadius.circular(14)),child: const Icon(Icons.sports_soccer,color: bg,size: 30)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Text('FAKHRI FOOTBALL',style: TextStyle(color: green,fontSize: 12,fontWeight: FontWeight.bold,letterSpacing: 1.3)),
          Text('عالم كرة القدم بين إيديك',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
        ])),
        IconButton(onPressed: ()=>Navigator.push(context,MaterialPageRoute(builder: (_) => const SettingsPage())),icon: const Icon(Icons.settings_outlined))
      ]),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(18),decoration: BoxDecoration(
        gradient: const LinearGradient(colors:[Color(0xFF173D31),Color(0xFF17232B)]),
        borderRadius: BorderRadius.circular(22),border: Border.all(color: green.withOpacity(.35))),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start,children:[
          Text('كل تفاصيل اللعبة في مكان واحد',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('المباريات • اللاعبين • الإصابات • التحليلات',style: TextStyle(color: Colors.white70)),
          SizedBox(height: 16),
          Row(children:[Icon(Icons.bolt,color:green),SizedBox(width:8),Text('مركز كرة القدم الشامل',style:TextStyle(color:green,fontWeight:FontWeight.w600))])
        ])),
      const SizedBox(height: 22),
      const SectionTitle('استكشف التطبيق'),
      const SizedBox(height: 12),
      GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,mainAxisSpacing:10,crossAxisSpacing:10,childAspectRatio:1.45,children:const [
        FeatureTile(Icons.calendar_month,'المباريات','النتائج والمواعيد'),
        FeatureTile(Icons.leaderboard,'الدوريات','الترتيب والهدافون'),
        FeatureTile(Icons.person_search,'اللاعبون','مسيرة وإحصائيات'),
        FeatureTile(Icons.healing,'الإصابات','الحالة والعودة'),
        FeatureTile(Icons.query_stats,'التوقعات','احتمالات مدروسة'),
        FeatureTile(Icons.compare_arrows,'المقارنات','لاعب ضد لاعب'),
      ]),
      const SizedBox(height: 20),
      const SectionTitle('ملاحظة البيانات'),
      const InfoCard(icon:Icons.info_outline,title:'اربط مصدر بياناتك',body:'التطبيق جاهز للواجهة والإعدادات. لإظهار نتائج وإحصائيات حقيقية، أدخل رابط API ومفتاح الوصول من الإعدادات. لا توجد نتائج تجريبية معروضة على أنها مباشرة.'),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  final String title; const SectionTitle(this.title,{super.key});
  @override Widget build(BuildContext context)=>Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold));
}
class FeatureTile extends StatelessWidget {
  final IconData icon; final String title,subtitle;
  const FeatureTile(this.icon,this.title,this.subtitle,{super.key});
  @override Widget build(BuildContext context)=>Container(
    padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[
      Icon(icon,color:green,size:27),const SizedBox(height:9),
      Text(title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)),
      Text(subtitle,style:const TextStyle(color:Colors.white60,fontSize:12)),
    ]));
}
class InfoCard extends StatelessWidget {
  final IconData icon; final String title,body;
  const InfoCard({super.key,required this.icon,required this.title,required this.body});
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(15),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Icon(icon,color:green),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:5),Text(body,style:const TextStyle(color:Colors.white70,height:1.4))
    ]))
  ])));
}

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});
  @override State<MatchesPage> createState()=>_MatchesPageState();
}
class _MatchesPageState extends State<MatchesPage> {
  bool loading=false; String? error; List<MatchItem> matches=[];
  Future<void> load() async {
    setState(() { loading=true; error=null; });
    final prefs=await SharedPreferences.getInstance();
    try {
      final rows=await FootballApi.fetchMatches(prefs.getString('api_endpoint')??'',prefs.getString('api_key')??'');
      setState(()=>matches=rows);
    } catch(e) { setState(()=>error=e.toString().replaceFirst('Exception: ','')); }
    finally { if(mounted)setState(()=>loading=false); }
  }
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('المباريات',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),
    const SizedBox(height:6),const Text('نتائج ومواعيد من مصدر البيانات الذي تختاره',style:TextStyle(color:Colors.white60)),
    const SizedBox(height:16),
    FilledButton.icon(onPressed:loading?null:load,icon:const Icon(Icons.refresh),label:Text(loading?'جارٍ التحميل...':'تحديث المباريات')),
    if(error!=null) Padding(padding:const EdgeInsets.only(top:12),child:InfoCard(icon:Icons.info_outline,title:'تعذر تحميل البيانات',body:error!)),
    if(matches.isEmpty&&error==null) const Padding(padding:EdgeInsets.only(top:18),child:InfoCard(icon:Icons.sports_soccer,title:'لا توجد بيانات محمّلة بعد',body:'أضف رابط API ومفتاحه من الإعدادات، ثم اضغط تحديث المباريات.')),
    ...matches.map((m)=>Padding(padding:const EdgeInsets.only(top:10),child:Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[
      Text(m.competition,style:const TextStyle(color:green,fontSize:12)),const SizedBox(height:10),
      Row(children:[Expanded(child:Text(m.home,textAlign:TextAlign.center)),Text(m.score,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),Expanded(child:Text(m.away,textAlign:TextAlign.center))]),
      const SizedBox(height:8),Text('${m.status}  ${m.time}',style:const TextStyle(color:Colors.white60,fontSize:12))
    ]))))),
  ]);
}

class LeaguesPage extends StatelessWidget {
  const LeaguesPage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('الدوريات والبطولات',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('صفحة مخصصة للترتيب والهدافين وجدول الجولات.',style:TextStyle(color:Colors.white60)),
    const SizedBox(height:16),
    for(final item in ['الدوري الإنجليزي الممتاز','الدوري الإسباني','الدوري المصري الممتاز','دوري أبطال أوروبا','الدوري الإيطالي','الدوري الألماني','الدوري الفرنسي'])
      Card(child:ListTile(leading:const Icon(Icons.emoji_events_outlined,color:green),title:Text(item),subtitle:const Text('يحتاج ربط API لعرض الترتيب الحقيقي'),trailing:const Icon(Icons.chevron_left))),
  ]);
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('التحليلات والتوقعات',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),
    const SizedBox(height:12),
    const InfoCard(icon:Icons.auto_graph,title:'توقع احتمالات المباراة',body:'يمكن بناء توقعات للفوز والتعادل والأهداف باستخدام نتائج تاريخية وأداء الفريقين والملعب والغيابات. يجب تدريب النموذج أو حسابه من بيانات موثوقة قبل عرض نسب فعلية.'),
    const SizedBox(height:10),
    const InfoCard(icon:Icons.compare_arrows,title:'مقارنة اللاعبين',body:'إحصائيات الأهداف والتمريرات والمشاركات والدقائق لكل موسم ولكل نادٍ، مع تطبيع الأرقام بحسب عدد المباريات لتكون المقارنة أكثر إنصافًا.'),
    const SizedBox(height:10),
    const InfoCard(icon:Icons.healing,title:'الإصابات والعودة',body:'نوع الإصابة وموعد العودة وحالة اللاعب ومصدر الخبر وتاريخ التحديث. المعلومات غير المؤكدة ستظهر بوضوح على أنها تقديرية.'),
    const SizedBox(height:10),
    const InfoCard(icon:Icons.timeline,title:'تطور الأداء',body:'رسوم أداء الموسم، المساهمات التهديفية، دقائق اللعب، وأفضل فترات اللاعب بعد ربط قاعدة البيانات.'),
  ]);
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('المزيد',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),
    const SizedBox(height:12),
    for(final item in [
      (Icons.person,'ملفات اللاعبين','المسيرة والأهداف والإحصائيات'),
      (Icons.local_hospital_outlined,'الإصابات والغيابات','نوع الإصابة وموعد العودة'),
      (Icons.swap_horiz,'سوق الانتقالات','الصفقات المؤكدة والشائعات'),
      (Icons.newspaper,'الأخبار','آخر أخبار الأندية'),
      (Icons.stadium,'التشكيلات','خطط 4-3-3 و4-2-3-1'),
      (Icons.star_outline,'المفضلة','فرق ولاعبون تتابعهم'),
      (Icons.notifications_none,'الإشعارات','الأهداف وبداية المباريات'),
    ]) Card(child:ListTile(leading:Icon(item.$1,color:green),title:Text(item.$2),subtitle:Text(item.$3),onTap:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${item.$2}: يتطلب ربط البيانات في المرحلة التالية.'))))),
    Card(child:ListTile(leading:const Icon(Icons.settings,color:green),title:const Text('الإعدادات'),subtitle:const Text('مصدر البيانات ومفتاح API'),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsPage())))),
  ]);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  final endpoint=TextEditingController(); final key=TextEditingController(); bool loaded=false;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{final p=await SharedPreferences.getInstance();endpoint.text=p.getString('api_endpoint')??'';key.text=p.getString('api_key')??'';if(mounted)setState(()=>loaded=true);}
  Future<void> _save()async{final p=await SharedPreferences.getInstance();await p.setString('api_endpoint',endpoint.text.trim());await p.setString('api_key',key.text.trim());if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ الإعدادات على الجهاز')));Navigator.pop(context);}}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('الإعدادات')),body:!loaded?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(16),children:[
    const Text('مصدر بيانات كرة القدم',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('أدخل endpoint المناسب لمزودك ومفتاح API. صيغة الرد تختلف بين الخدمات، وقد تحتاج إلى محول مخصص.',style:TextStyle(color:Colors.white70)),
    const SizedBox(height:16),TextField(controller:endpoint,keyboardType:TextInputType.url,decoration:const InputDecoration(labelText:'API endpoint',hintText:'https://example.com/matches',border:OutlineInputBorder())),
    const SizedBox(height:12),TextField(controller:key,obscureText:true,decoration:const InputDecoration(labelText:'API key',border:OutlineInputBorder())),
    const SizedBox(height:20),FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save),label:const Text('حفظ الإعدادات')),
    const SizedBox(height:12),const InfoCard(icon:Icons.security,title:'حماية المفتاح',body:'في تطبيق إنتاجي منشور، لا تضع مفتاحًا سريًا عالي الصلاحيات داخل التطبيق. الأفضل تمرير الطلبات الحساسة عبر خادم وسيط.'),
  ]));
}