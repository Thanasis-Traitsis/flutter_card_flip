# Flutter Flip Card Animation
![Header](https://github.com/Thanasis-Traitsis/flutter_card_flip/blob/main/assets/Flutter%20Flip%20Card%20Animation.png?raw=true)
Welcome fellow Flutter developers! Today, we’re diving into something really exciting: building a flip card animation from scratch. You know those satisfying card-flip effects you see in card board-games and bank applications? We'll create that using nothing but Flutter's built-in animation tools – no external packages needed. And don't worry, this is not an ordinary "copy-paste the code" article. We'll break down the animation principles that make this effect work, giving you the knowledge to create not just this flip animation, but any custom animation your app needs. Ready to upgrade your Flutter apps? Let's start by answering a question that I think you are all wondering.

### Why No Packages?

There are plenty of packages in Flutter that can help you create a flip animation in no time. But when you build it yourself, you gain a much better understanding of how animations work under the hood in Flutter. Plus, building it from scratch means you have full control and flexibility over the animation. You can customize it in ways that might not be possible with pre-built solutions.

Now that we got that out of the way, time to build our foundation. We will use a very simple UI because we want to focus on the animation.

## The UI Setup

Before diving into animations, let's create the basic building blocks of our card. We'll start with a simple card component that will represent the front face of the card.

The `FrontCard` widget, is just a basic card layout with a title and some placeholder text:

``` dart
class FrontCard extends StatelessWidget {
  const FrontCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.black,
          ),
          color: const Color.fromARGB(255, 164, 215, 235),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "💳 Flip the card",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting."),
        ],
      ),
    );
  }
}
```

The next step would be creating our `CardContainer` widget inside our Home Screen to properly position this card. As I said, we will keep the UI as simple as possible. 

``` dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CardContainer(),
      )
    );
  }
}

class CardContainer extends StatelessWidget {
  const CardContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FrontCard(),
    );
  }
}
```

## The Basic Logic

Let's build out the core mechanics of our flip card feature. Think of it like setting up a basic two-sided playing card - we can't see both sides at once, but we need to be able to switch between them.

First, we'll make a `BackCard` widget that mirrors our `FrontCard` structure but with different content and styling. This gives us a clear visual distinction between the front and back states of our card.

With both card faces ready, we need a way to switch between them. We'll transform our `CardContainer` into a stateful widget that tracks which side is currently visible using a boolean flag. When a user taps the card, we'll toggle between the front and back faces.

``` dart
class CardContainer extends StatefulWidget {
  const CardContainer({super.key});

  @override
  State<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer> {
  bool isFront = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFront = !isFront;
        });
      },
      child: Container(
        child: isFront ? FrontCard() : BackCard(),
      ),
    );
  }
}

```
<img src="https://github.com/Thanasis-Traitsis/flutter_card_flip/blob/main/assets/basic_logic.png?raw=true" alt="Basic Logic" width="600" height="auto">

## Flip Animation

Enough with the boring part, don't you think? Now that we’ve established the basic logic for toggling between the front and back sides of our card, let’s take things to the next level by adding a smooth flip animation. Rather than instantly switching between the two card faces, we’ll implement a visually engaging transition that mimics the natural motion of a card flipping through space. 

In this section, we’ll break down the animation mechanism step by step, explain how the code works, and highlight the key parts that bring the flip animation to life.

### Animation Controller

To bring our card flip animation to life, we need an `AnimationController`. This is the backbone of the animation mechanism in Flutter, giving us complete control over how and when the animation plays. With a controller we can manage:
- The duration of the animation.
- The flow of the animation. For example, we can **start**, **stop**, **reverse**, or **repeat** the animation as needed.
- Synchronization with the screen. By using the `vsync` keyword, we ensure that the animation we build is tied with the screen's refresh rate system.
- Every single value of the animation from the beginning to the very end. The controller has a range of values from **0** to **1**, pointing the start and the finish of the animation, giving us full access of the whole proccess.

In our case, we will use our AnimationController to rotate the `FrontCard` 180°, but first we need to initialize it. 

``` dart
late AnimationController _cardFlipController;

  @override
  void initState() {
    super.initState();

    _cardFlipController = AnimationController(
      duration: const Duration(seconds: 2), // Animation lasts 2 seconds
      vsync: this, // Syncs with the screen refresh rate
    );
  }
```

At this point, you might see an error on your screen because of the `this` keyword in the `vsync` parameter. If your editor seems confused, don’t worry—this is a common issue. Essentially, your program is saying, *"Okay, what the f...k is this?"*

Relax, dear editor. We can fix this pretty easily by adding a mixin to our class:

```dart
class _CardContainerState extends State<CardContainer>
    with SingleTickerProviderStateMixin {
        ...
    }
```

Now, if you’re feeling ambitious and want multiple animations in the same widget, just remove the word "Single" from the mixin, and you’re good to go. (Yes, it’s that easy!)

### Animation Setup

With the **AnimationController** set up, we are ready to build the actual animation. This is where `Tween` comes into play. The `Tween` help us provide the actual values of our animation. Remember in the previous section, where we said that we can define the values from the beginning to the end? This is the place where we can set these values. In our case, we need to start from **0°**, and produce half a circle, which means **180°**.

``` dart
late AnimationController _cardFlipController;

  @override
  void initState() {
    super.initState();

    _cardFlipController = AnimationController(
      duration: const Duration(seconds: 2), // Animation lasts 2 seconds
      vsync: this, // Syncs with the screen refresh rate
    );
    
    _cardFlipAnimation = Tween(
      begin: 0.0, // ---> 0°
      end: pi, // ---> 180°
    ).animate(_cardFlipController); // Place the animation controller here
  }
```

But wait, what is this `pi`? Thought you never ask... TIME FOR SOME MATHS!

#### Why Do We Rotate the Card to π?

The value of π radians (equivalent to 180°) represents half of a full rotation. By transitioning to this value, we create the illusion of flipping the card over to reveal its back side. This provides the visual "turning" motion that feels natural.

We have access to this value by importing the `dart:math`
```dart
import 'dart:math' show pi;
```

<img src="https://github.com/Thanasis-Traitsis/flutter_card_flip/blob/main/assets/circle_board.png?raw=true" alt="Board Image" width="600" height="auto">

Perfect, now all that's left, is updating our UI, so we can apply this amazing animation.

### Updating UI

Connecting the animation logic with the UI, will not work with the simple widgets. We need something specifically for this job. Enter the `Transform` widget, which allows us to manipulate the visual properties of our card, like its position, size, and most importantly—its rotation.

But in order to visualize our animation, we will need another Widget, the `AnimationBuilder` which will recreate the UI based on the animation. This widget listens to changes in the animation’s value and rebuilds the UI at every frame, ensuring the flip appears smooth and fluid.

Here’s how it all comes together:
```dart
@override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isFront) {
          _cardFlipController.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _cardFlipAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // Perspective for the realistic flip of the card
              ..rotateY(
                _cardFlipAnimation.value,
              ),
            child: child,
          );
        },
        child: isFront
            ? FrontCard()
            : BackCard(),
      ),
    );
  }
```

I know that the `Transform` widget, might look a bit confusing to you, so let's break it down line by line.

- **Alignment.center:** This ensures the card rotates around its center point. Without this, the rotation might pivot from an awkward position, like the top-left corner. 
- **setEntry:** Adds a perspective effect, simulating 3D depth. Without this line, the card flip would look flat, as if it were rotating in 2D space.
- **rotateY:** Rotates the card along the Y-axis based on the animation progress. This line drives the actual flipping motion.

The image below, can help you visualize everything we discussed above:

[[ ROTATION IMAGE ]]

### Completing the animation - Switching to BackCard

Our flip animation is looking amazing! However, there's one last thing that needs to be fixed. We only ever see the `FrontCard`. Even though the animation flips smoothly, the back side never appears because we never swap the UI to display the `BackCard`.

To achieve this swap seamlessly, we need to find the most efficient point in time during the animation, and change our two widgets. If you think about it, there is a very specific moment, where we cannot see the face of the card, because it is turned sideways. That's our chance to act!

#### How Do We Implement This?
We use an animation listener on our AnimationController to detect when the animation reaches its halfway point. When it does, we toggle the isFront boolean.

```dart
class CardContainer extends StatefulWidget {
  const CardContainer({super.key});

  @override
  State<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardFlipController;
  late Animation<double> _cardFlipAnimation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();

    _cardFlipController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _cardFlipAnimation = Tween(
      begin: 0.0,
      end: pi,
    ).animate(_cardFlipController);

    // Add a listener to the animation controller
    _cardFlipController.addListener(() {
      // Check if animation is at halfway point (π / 2)
      if (_cardFlipController.value >= 0.5 && isFront) {
        setState(() {
          isFront = false; // Switch to back card
        });
      } else if (_cardFlipController.value < 0.5 && !isFront) {
        setState(() {
          isFront = true; // Switch to front card
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isFront) {
          _cardFlipController.forward();
        } else {
          _cardFlipController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _cardFlipAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(
                _cardFlipAnimation.value,
              ),
            child: child,
          );
        },
        child: isFront
            ? FrontCard()
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(pi), // Rotate 180° for the starting position of the back card
                child: BackCard(),
              ),
      ),
    );
  }
}
```

Before we move on, let’s address one final detail. If you look at the code, you'll notice that when displaying the `BackCard`, we apply an additional 180° rotation:
```dart
Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(pi), // Rotate 180° for the starting position of the back card
        child: BackCard(),
        ),
```

#### Why is this necessary?

Since our animation only rotates the card from 0 to π (180°), we need to ensure that the BackCard is correctly oriented when it appears.

Without this extra rotation, the `BackCard` would appear upside down when it replaces the `FrontCard`. By pre-rotating the `BackCard` by π (180°), we align it properly so that when it becomes visible, it appears in the correct orientation.

## Wrapping it up

And there you have it! You’ve successfully developed and fully understand how to create a smooth and realistic **flip animation** in Flutter. More importantly, you now grasp the fundamentals of **3D** transformations, perspective effects, and animation control.

With this knowledge, you can level up your application by incorporating this awesome effect into any UI element like flashcards, game mechanics, or stylish flipping menus.

Buuuuut before you go...allow me to add one last thing to this tutorial. I would like to include everything around this flip animation, so whenever you step into something challenging while implementing something similar, this would be the perfect place to jump back into and find the solution you need. I promise it's the last topic we cover.

### Card Views with Different Heights – The Asymmetric Flip

This is a pretty special case. You will almost never need an implementation like this in a typical app. However, if you ever find yourself needing an asymmetric card flip animation, where the front and back of the card have different heights, this section has you covered.

I know what you’re thinking: *"Why would anyone need this?"* Well, trust me, there are people out there desperately looking for this solution (I was one of them).

#### The Problem

Normally, a card flip animation assumes that both sides of the card are the same size. However, in some UI designs, the back card might be larger because it contains more content. This creates an issue:

- If we use a fixed height, one side might be cut off.
- If we let the card resize mid-flip, the content above and below the card will move everytime the user flips the card, providing a very bad user experience to the user.

The solution? We need to measure both cards' heights before displaying them and then set a consistent maximum height for the animation.

#### The Solution

Here is how we solve our asymmetric problem in a few simple steps:

- Create `GlobalKeys` for both Front and Back widgets, so you can measure their heights
- Store the maximum height inside the `maxHeight` variable
- Use `OffStage` widget in order to build the cards (so we can measure their heights), but without displaying them to the user

Here's how the final code will look like:

```dart
import 'package:card_rotation/card/back_card.dart';
import 'package:card_rotation/card/front_card.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;

class CardContainer extends StatefulWidget {
  const CardContainer({super.key});

  @override
  State<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardFlipController;
  late Animation<double> _cardFlipAnimation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();

    _cardFlipController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _cardFlipAnimation = Tween(
      begin: 0.0,
      end: pi,
    ).animate(_cardFlipController);

    _cardFlipController.addListener(() {
      if (_cardFlipController.value >= 0.5 && isFront) {
        setState(() {
          isFront = false;
        });
      } else if (_cardFlipController.value < 0.5 && !isFront) {
        setState(() {
          isFront = true;
        });
      }
    });

    // Measure the heights after the first layout phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      measureHeights();
    });
  }

  final GlobalKey _frontCardKey = GlobalKey(); // GlobalKey for FrontCard
  final GlobalKey _backCardKey = GlobalKey(); // GlobalKey for BackCard

  late double frontCardHeight;
  late double backCardHeight;
  double? maxHeight;

  @override
  void dispose() {
    _cardFlipController.dispose();
    super.dispose();
  }

  // Function to measure heights of FrontCard and BackCard
  void measureHeights() {
    final frontRenderBox =
        _frontCardKey.currentContext?.findRenderObject() as RenderBox?;
    final backRenderBox =
        _backCardKey.currentContext?.findRenderObject() as RenderBox?;

    if (frontRenderBox != null && backRenderBox != null) {
      setState(() {
        frontCardHeight = frontRenderBox.size.height;
        backCardHeight = backRenderBox.size.height;
        maxHeight =
            frontCardHeight > backCardHeight ? frontCardHeight : backCardHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Offstage(
          child: FrontCard(
            key: _frontCardKey, // Attach the GlobalKey here
          ),
        ),
        Offstage(
          child: BackCard(
            key: _backCardKey, // Attach the GlobalKey here
          ),
        ),
        SizedBox(
          height: maxHeight,
          child: GestureDetector(
            onTap: () {
              if (isFront) {
                _cardFlipController.forward();
              } else {
                _cardFlipController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _cardFlipAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(
                      _cardFlipAnimation.value,
                    ),
                  child: child,
                );
              },
              child: isFront
                  ? FrontCard()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(pi),
                      child: BackCard(),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
```

Finally, we have to mention that this is not a space-efficient solution. We create two extra widgets (`FrontCard` and `BackCard`) that never actually appear on the screen. Overloading the app with unused UI elements is bad practice and can lead to performance issues, especially in more complex applications. As a developer, your goal should always be to write efficient, scalable code. However, sometimes, special problems require special solutions, and that’s okay as long as you understand the trade-offs.

## Conclusion

And there you have it everyone. Another Flutter tutorial has come to an end. I hope this guide helped you find exactly what you were looking for when searching for a **Card Flip Animation**. We covered everything from the fundamentals of an `AnimationController` to the explanation of 3D transformations in Flutter. Along the way, we explored perspective effects, UI swapping, and even handling asymmetric card flips, leaving no stone unturned!

Now, you're fully equipped with a solid understanding of Flutter animations. Whether you want to implement a card flip, or even more complex 3D animations, you have all the tools you need to bring your ideas to life. Until we meet again on another coding adventure...Happy Coding!!

If you enjoyed this article and want to stay connected, feel free to connect with me on [LinkedIn](https://www.linkedin.com/in/thanasis-traitsis/).

If you'd like to dive deeper into the code and contribute to the project, visit the repository on [GitHub](https://github.com/Thanasis-Traitsis/flutter_card_flip).

Was this guide helpful? Consider buying me a coffee!☕️ Your contribution goes a long way in fuelling future content and projects. [Buy Me a Coffee](https://www.buymeacoffee.com/thanasis_traitsis).

Feel free to reach out if you have any questions or need further guidance. Cheers to your future Flutter projects!
