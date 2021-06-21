import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          CarouselSlider(
            items: [
              //1st Image of Slider
              Container(
                margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://www.sonypictures.com/sites/default/files/styles/max_560x840/public/title-key-art/spiderman_verse_rating_0.jpg?itok=N_U_lGHQ"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              //2nd Image of Slider
              Container(
                margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://www.sonypictures.com/sites/default/files/styles/max_560x840/public/title-key-art/spiderman_verse_rating_0.jpg?itok=N_U_lGHQ"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              //3rd Image of Slider
              Container(
                margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://d2skuhm0vrry40.cloudfront.net/2020/articles/2020-10-30-13-40/-1604065215602.jpg/EG11/thumbnail/750x422/format/jpg/quality/60"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              //4th Image of Slider
              Container(
                margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://www.sonypictures.com/sites/default/files/styles/max_560x840/public/title-key-art/spiderman_verse_rating_0.jpg?itok=N_U_lGHQ"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              //5th Image of Slider
              Container(
                margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://www.sonypictures.com/sites/default/files/styles/max_560x840/public/title-key-art/spiderman_verse_rating_0.jpg?itok=N_U_lGHQ"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],

            //Slider Container properties
            options: CarouselOptions(
              height: 180.0,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
