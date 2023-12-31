import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:url_launcher/url_launcher.dart';

Style globalHTMLStyle(BuildContext context) {
  return Style(
    backgroundColor: Theme.of(context).colorScheme.surface,
    fontSize: FontSize.large,
    color: Theme.of(context).colorScheme.onSurface,
  );
}

class PostViewerPage extends HookWidget {
  const PostViewerPage({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        actions: [
          IconButton(
            onPressed: () {
              Share.shareUri(Uri.parse(post.postLink));
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(post.creators.first.name),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              children: [
                ...(post.categories
                    .map((e) => (e != "")
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(e),
                              padding: const EdgeInsets.all(4),
                            ),
                          )
                        : Container())
                    .toList()),
                ...(post.customCategories
                    .map((e) => (e != "")
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(e),
                              padding: const EdgeInsets.all(4),
                            ),
                          )
                        : Container())
                    .toList())
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Icon(Icons.date_range),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  "${post.publishDate.day}/${post.publishDate.month}/${post.publishDate.year} at ${post.publishDate.hour}:${post.publishDate.minute}",
                ),
              ],
            ),
            const Divider(),
            /*Html(
              onLinkTap: (url, attributes, element) {
                launchUrl(Uri.parse(url!));
              },
              data: post.content,
              style: {
                "span": globalHTMLStyle(context),
                "div": globalHTMLStyle(context),
                "img": globalHTMLStyle(context)
              },
            ),*/
            HtmlWidget(
              post.content,
              onTapUrl: (url) => launchUrl(
                Uri.parse(url),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
