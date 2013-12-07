Steinbrenner Oracle App
=======================

- **Todo**
	- Update launch images
		- Include Oracle logo text
		- Make custom ones instead of Gimp'ed images
	- See below about stats
	- See below about WP plugin
		- and Drupal migration/plugin/framework
	- Dynamic type - about pages and content pages
	- Content display - show title like in Mail app
- **Stats ideas**
	- Start over (personal website) with Drupal 7
	- Create module that adds 'app' content type w/ fields for icons, screenshots, price, App Store link, availability date, ...
	- Complementary iOS library that communicates with the server and uploads statistics
		- Sends iOS version, app version, device type, screen size, ... once per version
		- Records what version the server has and when that is different from the version on the device upload w/ old version and new version
		- Periodically send average session length
	- Module 'autoingests' from iTunes daily on cron
	- 'App Statistics' tab on app nodes with graphs and so on about the app
		- Show number of total users, number of users per version, number of users per device, number of users per iOS version, number of sales vs. number of installs
		- Predict lowest deployment target necessary (if only <1% of users are on 6, then there's no reason to support it)
	- iOS app client for viewing statistics

- **WordPress plugin ideas**
	- Exposes API for getting categories, posts and their content, pages and their content
	- More reliable, paginated way to get posts than Atom feed
	- API design notes in back of tech binder
	- Publish plugin and iOS library as FOSS
	- Future: take over website and migrate to Drupal? Then use Drupal iOS SDK
- **Website notes**
	- Hosted by GoDaddy (grrr...)
	- Logo font is [Antique Central](http://www.myfonts.com/fonts/aboutype/antique-central/) - $19.99 per subfont, admitted that it is pirated download
	- Theme is [Magnifica](http://themeforest.net/item/magnifica-blog-news-magazine-theme/135470) - $40
		- Refers to /wp-content/themes/magnifica_old, which is not Magnifica, and has no results on Google
	- Includes Cufon font [Yanone Kaffeesatz](http://yanone.de/typedesign/kaffeesatz/), which is free
	- From [/](http://oraclenewspaper.com/): `<p class="nemonn">By nttc<a href="http://www.noteletrackcash4ps.com/" title="payday Loans">Payday Loan</a></p>`
		- Hacked in ad injected by another site on the same server - http://wordpress.org/support/topic/site-hacked-nemonn-tag-infected-with-scam-description
	- Uses (at least) these plugins:
		- [WP-Polls](http://wordpress.org/plugins/wp-polls/)
		- [Captcha](http://wordpress.org/plugins/captcha/)
		- [WP Easy Gallery](http://wordpress.org/plugins/wp-easy-gallery/)
		- [AdRotate](http://wordpress.org/plugins/adrotate/)
		- [Background Control](http://wordpress.org/plugins/background-control/)
		- [WP-Table Reloaded](http://wordpress.org/plugins/wp-table-reloaded/)