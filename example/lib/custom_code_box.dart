// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

import 'common/themes.dart';

final builtinLanguages = {
  'go': go,
  'java': java,
  'python': python,
  'scala': scala,
  'dart': dart,
};
final allLanguages = {...builtinLanguages};

class CustomCodeBox extends StatefulWidget {
  final String language;
  final String theme;

  const CustomCodeBox({
    super.key,
    required this.language,
    required this.theme,
  });

  @override
  State<CustomCodeBox> createState() => _CustomCodeBoxState();
}

class _CustomCodeBoxState extends State<CustomCodeBox> {
  String? language;
  String? theme;
  bool? reset;

  @override
  void initState() {
    super.initState();
    language = widget.language;
    theme = widget.theme;
    reset = false;
  }

  List<String?> languageList = <String>[
    'java',
    'go',
    'python',
    'scala',
    'dart',
  ];

  List<String?> themeList = <String>[
    'monokai-sublime',
    'a11y-dark',
    'an-old-hope',
    'vs2015',
    'vs',
    'atom-one-dark',
  ];

  Widget buildDropdown(
    Iterable<String?> choices,
    String value,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return DropdownButton<String>(
      value: value,
      items: choices.map((String? value) {
        return DropdownMenuItem<String>(
          value: value,
          child: value == null
              ? const Divider()
              : Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      icon: Icon(icon, color: Colors.white),
      onChanged: onChanged,
      dropdownColor: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    final codeDropdown =
        buildDropdown(languageList, language!, Icons.code, (val) {
      if (val == null) return;
      setState(() => language = val);
    });
    final themeDropdown =
        buildDropdown(themeList, theme!, Icons.color_lens, (val) {
      if (val == null) return;
      setState(() => theme = val);
    });
    final resetButton = TextButton.icon(
      icon: const Icon(Icons.delete, color: Colors.white),
      label: const Text('Reset', style: TextStyle(color: Colors.white)),
      onPressed: () {
        setState(() {
          reset = !reset!;
        });
      },
    );

    final buttons = Container(
      height: MediaQuery.of(context).size.height / 13,
      color: Colors.deepPurple[900],
      child: Row(
        children: [
          const Spacer(flex: 2),
          const Text(
            'Code Editor by Akvelon',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          const Spacer(flex: 35),
          codeDropdown,
          const Spacer(),
          themeDropdown,
          const Spacer(),
          resetButton,
        ],
      ),
    );

    final codeField = InnerField(
      key: ValueKey('$language - $theme - $reset'),
      language: language!,
      theme: theme!,
    );

    return Column(
      children: [
        buttons,
        codeField,
      ],
    );
  }
}

class InnerField extends StatefulWidget {
  final String language;
  final String theme;

  const InnerField({
    super.key,
    required this.language,
    required this.theme,
  });

  @override
  State<InnerField> createState() => _InnerFieldState();
}

class _InnerFieldState extends State<InnerField> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      language: allLanguages[widget.language],
      text: '''
private class MyClass {
  //comment1
  //comment2
  
  void method1() {
    if (false) {// [START section1]
      return;
    }// [END section1]
  }

  void method2() {// [START section2]
    return;
  }// [END section2]
}
''',
//       text: r'''
// /*
//  * Licensed to the Apache Software Foundation (ASF) under one
//  * or more contributor license agreements.  See the NOTICE file
//  * distributed with this work for additional information
//  * regarding copyright ownership.  The ASF licenses this file
//  * to you under the Apache License, Version 2.0 (the
//  * "License"); you may not use this file except in compliance
//  * with the License.  You may obtain a copy of the License at
//  *
//  *     http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
// package org.apache.beam.examples;
//
// import java.util.Arrays;
// import org.apache.beam.sdk.Pipeline;
// import org.apache.beam.sdk.io.TextIO;
// import org.apache.beam.sdk.options.PipelineOptions;
// import org.apache.beam.sdk.options.PipelineOptionsFactory;
// import org.apache.beam.sdk.transforms.Count;
// import org.apache.beam.sdk.transforms.Filter;
// import org.apache.beam.sdk.transforms.FlatMapElements;
// import org.apache.beam.sdk.transforms.MapElements;
// import org.apache.beam.sdk.values.KV;
// import org.apache.beam.sdk.values.TypeDescriptors;
//
// /**
//  * An example that counts words in Shakespeare.
//  *
//  * <p>This class, {@link MinimalWordCount}, is the first in a series of four successively more
//  * detailed 'word count' examples. Here, for simplicity, we don't show any error-checking or
//  * argument processing, and focus on construction of the pipeline, which chains together the
//  * application of core transforms.
//  *
//  * <p>Next, see the {@link WordCount} pipeline, then the {@link DebuggingWordCount}, and finally the
//  * {@link WindowedWordCount} pipeline, for more detailed examples that introduce additional
//  * concepts.
//  *
//  * <p>Concepts:
//  *
//  * <pre>
//  *   1. Reading data from text files
//  *   2. Specifying 'inline' transforms
//  *   3. Counting items in a PCollection
//  *   4. Writing data to text files
//  * </pre>
//  *
//  * <p>No arguments are required to run this pipeline. It will be executed with the DirectRunner. You
//  * can see the results in the output files in your current working directory, with names like
//  * "wordcounts-00001-of-00005. When running on a distributed service, you would use an appropriate
//  * file service.
//  */
// public class MinimalWordCount {
//
//   public static void main(String[] args) {
//
//     // Create a PipelineOptions object. This object lets us set various execution
//     // options for our pipeline, such as the runner you wish to use. This example
//     // will run with the DirectRunner by default, based on the class path configured
//     // in its dependencies.
//     PipelineOptions options = PipelineOptionsFactory.create();
//
//     // In order to run your pipeline, you need to make following runner specific changes:
//     //
//     // CHANGE 1/3: Select a Beam runner, such as BlockingDataflowRunner
//     // or FlinkRunner.
//     // CHANGE 2/3: Specify runner-required options.
//     // For BlockingDataflowRunner, set project and temp location as follows:
//     //   DataflowPipelineOptions dataflowOptions = options.as(DataflowPipelineOptions.class);
//     //   dataflowOptions.setRunner(BlockingDataflowRunner.class);
//     //   dataflowOptions.setProject("SET_YOUR_PROJECT_ID_HERE");
//     //   dataflowOptions.setTempLocation("gs://SET_YOUR_BUCKET_NAME_HERE/AND_TEMP_DIRECTORY");
//     // For FlinkRunner, set the runner as follows. See {@code FlinkPipelineOptions}
//     // for more details.
//     //   options.as(FlinkPipelineOptions.class)
//     //      .setRunner(FlinkRunner.class);
//
//     // Create the Pipeline object with the options we defined above
//     Pipeline p = Pipeline.create(options);
//
//     // Concept #1: Apply a root transform to the pipeline; in this case, TextIO.Read to read a set
//     // of input text files. TextIO.Read returns a PCollection where each element is one line from
//     // the input text (a set of Shakespeare's texts).
//
//     // This example reads from a public dataset containing the text of King Lear.
//     p.apply(TextIO.read().from("gs://apache-beam-samples/shakespeare/kinglear.txt"))
//
//         // Concept #2: Apply a FlatMapElements transform the PCollection of text lines.
//         // This transform splits the lines in PCollection<String>, where each element is an
//         // individual word in Shakespeare's collected texts.
//         .apply(
//             FlatMapElements.into(TypeDescriptors.strings())
//                 .via((String line) -> Arrays.asList(line.split("[^\\p{L}]+"))))
//         // We use a Filter transform to avoid empty word
//         .apply(Filter.by((String word) -> !word.isEmpty()))
//         // Concept #3: Apply the Count transform to our PCollection of individual words. The Count
//         // transform returns a new PCollection of key/value pairs, where each key represents a
//         // unique word in the text. The associated value is the occurrence count for that word.
//         .apply(Count.perElement())
//         // Apply a MapElements transform that formats our PCollection of word counts into a
//         // printable string, suitable for writing to an output file.
//         .apply(
//             MapElements.into(TypeDescriptors.strings())
//                 .via(
//                     (KV<String, Long> wordCount) ->
//                         wordCount.getKey() + ": " + wordCount.getValue()))
//         // Concept #4: Apply a write transform, TextIO.Write, at the end of the pipeline.
//         // TextIO.Write writes the contents of a PCollection (in this case, our PCollection of
//         // formatted strings) to a series of text files.
//         //
//         // By default, it will write to a set of files with names like wordcounts-00001-of-00005
//         .apply(TextIO.write().to("wordcounts"));
//
//     p.run().waitUntilFinish();
//   }
// }
// ''',
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
      readOnlySectionNames: {'section1', 'nonexistent'},
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = themes[widget.theme];

    return Container(
      color: theme?['root']?.backgroundColor,
      height: MediaQuery.of(context).size.height / 13 * 12,
      child: CodeTheme(
        data: CodeThemeData(styles: theme),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: CodeField(
                controller: _codeController!,
                textStyle: const TextStyle(fontFamily: 'SourceCode'),
                lineNumberStyle: const LineNumberStyle(
                  textStyle: TextStyle(
                    fontFamily: 'Tahoma', // Ignored
                    color: Colors.purple,
                    fontSize: 30, // Ignored
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
