import 'package:dart_rss/domain/atom_feed.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sst_announcer/logic/database/post_storage/database.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:sst_announcer/logic/extensions/atom_item_extensions.dart';

part 'db_provider.g.dart';

@Riverpod(keepAlive: true)
class DbInstance extends _$DbInstance {
  AppDatabase db = AppDatabase();

  @override
  FutureOr<List<Post>> build() async {
    return db.getAllPosts();
  }

  Future filteredPosts(String? searchTerm, List<String>? categories) async {
    var posts = await db.getAllPosts();

    if ((searchTerm == null || searchTerm == "") && categories == null) {
      ref.invalidateSelf();
    }

    if (searchTerm != null && searchTerm != "") {
      posts = posts
          .where((element) =>
              element.title.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    if (categories != null) {
      posts = posts.where((element) {
        // If the post contains at lease one category which is in the categories parameter accept it
        if (element.customCategories
            .any((element) => categories.contains(element))) {
          return true;
        }
        return false;
      }).toList();
    }

    state = AsyncData(posts);
  }

  Future fetchMorePosts({int? numberToFetch}) async {
    var url = Uri.parse(
        "https://www.blogger.com/feeds/2263345748458699524/posts/default?start-index=${state.value?.length == null || state.value?.isEmpty == true ? 1 : state.value!.length + 1}&max-results=${numberToFetch ?? 10}");
    var response = await http.get(url);

    print(await getApplicationDocumentsDirectory());

    var atomFeed = AtomFeed.parse(response.body);

    var posts = atomFeed.items.map((e) => e.toCustomFormat());

    await db.batch((batch) {
      batch.insertAll(
          db.posts,
          posts.map((e) => PostsCompanion(
                uid: Value(e.uid),
                title: Value(e.title),
                content: Value(e.content),
                creators: Value(e.creators.toString()),
                postLink: Value(e.postLink),
                categories: Value(e.categories.toString()),
                publishDate: Value(e.publishDate),
                modifiedDate: Value(e.modifiedDate),
                customCategories: Value(e.customCategories.toString()),
              )),
          mode: InsertMode.insertOrReplace);
    });

    state = AsyncValue.data([...(state.value ?? []), ...posts]);
  }
}
