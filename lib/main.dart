import "dart:async";

import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:whose_turn/config.dart";

void main() async {
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Whose Turn",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    supabase
        .from("countries")
        .stream(primaryKey: ["id"]).listen((List<Map<String, dynamic>> data) {
      // Do something awesome with the data
      print("stream.listen");
      print(data);
    });

    supabase
        .channel("public:countries")
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: "public",
            table: "countries",
            callback: (payload) {
              print("Change received: ${payload.toString()}");
            })
        .subscribe();

    final StreamSubscription<AuthState> authSubscription =
        supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print('event: $event, session: $session');

      switch (event) {
        case AuthChangeEvent.initialSession:
          // handle initial session
          print("initial session");
        case AuthChangeEvent.signedIn:
          // handle signed in
          print("signed in");
        case AuthChangeEvent.signedOut:
          // handle signed out
          print("signed out");
        case AuthChangeEvent.passwordRecovery:
          // handle password recovery
          print("password recovery");
        case AuthChangeEvent.tokenRefreshed:
          // handle token refreshed
          print("token refreshed");
        case AuthChangeEvent.userUpdated:
          // handle user updated
          print("user updated");
        case AuthChangeEvent.userDeleted:
          // handle user deleted
          print("user deleted");
        case AuthChangeEvent.mfaChallengeVerified:
          // handle mfa challenge verified
          print("mfa challenge verified");
      }
    });
  }

  void fetchData() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select();
    print(data);
  }

  void insertData() async {
    await supabase.from("countries").insert({"name": "China"});
    fetchData();
  }

  void updateData() async {
    await supabase
        .from("countries")
        .update({"name": "Taiwan"}).match({"name": "China"});
    // fetchData();
  }

  void deleteData() async {
    await supabase.from("countries").delete().match({"name": "Japan"});
    fetchData();
  }

  void selectEqualTo() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().eq("name", "Korea");
    print(data);
  }

  void selectNotEqualTo() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select("name").neq("name", "China");
    print(data);
  }

  void selectGreaterThan() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().gt("id", 2);
    print(data);
  }

  void selectGreaterThanOrEqualTo() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().gte("id", 2);
    print(data);
  }

  void selectLessThan() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().lt("id", 2);
    print(data);
  }

  void selectLessThanOrEqualTo() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().lte("id", 2);
    print(data);
  }

  void selectMatchPattern() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().like("name", "%rea%");
    print(data);
  }

  void selectMatchCaseInsensitivePattern() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().ilike("name", "%REA%");
    print(data);
  }

  void selectIsValue() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().isFilter("name", null);
    print(data);
  }

  void selectInArray() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("countries")
        .select()
        .inFilter("name", ["Korea", "Japan"]);
    print(data);
  }

  void containsEveryElementInValue() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("issues")
        .select()
        .contains("tags", ["is:open", "priority:low"]);
    print(data);
  }

  void containedByValue() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("classes")
        .select("name")
        .containedBy("days", ["monday", "tuesday", "wednesday", "friday"]);
    print(data);
  }

  void greaterThanARange() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("reservations")
        .select()
        .rangeGt("during", "[2000-01-02 08:00, 2000-01-02 09:00)");
    print(data);
  }

  void greaterThanOrEqualToARange() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("reservations")
        .select()
        .rangeGte("during", "[2000-01-02 08:30, 2000-01-02 09:30)");
    print(data);
  }

  void lessThanARange() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("reservations")
        .select()
        .rangeLt("during", "[2000-01-01 15:00, 2000-01-01 16:00)");
    print(data);
  }

  void lessThanOrEqualToARange() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("reservations")
        .select()
        .rangeLte("during", "[2000-01-01 15:00, 2000-01-01 16:00)");
    print(data);
  }

  void mutuallyExclusiveToARange() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("reservations")
        .select()
        .rangeAdjacent("during", "[2000-01-01 12:00, 2000-01-01 13:00)");
    print(data);
  }

  void withACommonElement() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("issues")
        .select("title")
        .overlaps("tags", ["is:closed", "severity:high"]);
    print(data);
  }

  void matchAString() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("texts")
        .select("content")
        .textSearch("content", "\"eggs\" & \"ham\"", config: "english");
    print(data);
  }

  void matchAnAssociatedValue() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("countries")
        .select()
        .match({"id": 4, "name": "Korea"});
    print(data);
  }

  void dontMatchTheFilter() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select().not("name", "is", null);
    print(data);
  }

  void matchAtLeastOneFilter() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("countries")
        .select("name")
        .or("id.eq.2,name.eq.Algeria");
    print(data);
  }

  void matchTheFilter() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("countries")
        .select()
        .filter("name", "in", "(\"Korea\",\"Japan\")");
    print(data);
  }

  void returnDataAfterInserting() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("countries")
        .upsert({"id": 1, "name": "Algeria"}).select();
    print(data);
  }

  void orderTheResults() async {
    final List<Map<String, dynamic>> data = await supabase
        .from("countries")
        .select("id, name")
        .order("id", ascending: false);
    print(data);
  }

  void limitTheNumberOfRowsReturned() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select("name").limit(1);
    print(data);
  }

  void limitTheQueryToARange() async {
    final List<Map<String, dynamic>> data =
        await supabase.from("countries").select("name").range(0, 1);
    print(data);
  }

  void retrieveOneRowOfData() async {
    final Map<String, dynamic> data =
        await supabase.from("countries").select("name").limit(1).single();
    print(data);
  }

  void retrieveZeroOrOneRowOfData() async {
    final Map<String, dynamic>? data = await supabase
        .from("countries")
        .select()
        .eq("name", "Singapore")
        .maybeSingle();
    print(data);
  }

  void retrieveAsACSV() async {
    final String data = await supabase.from("countries").select().csv();
    print(data);
  }

  void usingExplain() async {
    final String data = await supabase.from("countries").select().explain();
    print(data);
  }

  void createANewUser() async {
    final AuthResponse res = await supabase.auth.signUp(
      email: 'example@email.com',
      password: 'example-password',
    );
    final Session? session = res.session;
    final User? user = res.user;
    print(session);
    print(user);
  }

  void createAnAnonymousUser() async {
    final AuthResponse data = await supabase.auth.signInAnonymously();
    print(data);
  }

  void signInAUser() async {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: 'example@email.com',
      password: 'example-password',
    );
    final Session? session = res.session;
    final User? user = res.user;
    print(session);
    print(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: updateData,
      ),
    );
  }
}
