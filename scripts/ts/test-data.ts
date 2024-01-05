import fs from "fs";

export type TestEvent =
  | "runStart"
  | "testCompleted"
  | "testFailed"
  | "runComplete";

export type TestType = "test" | "example";
export type TestVisibility = "public" | "hidden" | "ignore";

export interface RawParsedTest {
  event: TestEvent;
  status: "pass" | "fail";
  labels: string[];
  failures: string[];
  duration: string;
}

export interface TestData {
  event: TestEvent;
  status: "pass" | "fail";
  type: TestType;
  visibility: TestVisibility;
  labels: string[];
  failures: string[];
  duration: string;
}

export function parseTest(raw: RawParsedTest): TestData {
  function inner(t: RawParsedTest): TestData {
    if (t.labels[0].includes("VerifyExamples")) {
      let labels = t.labels[0].split(".").slice(0, -1);
      const tagRe = /\{- (?<tag>\w+) -\}/g;
      const testDesc = t.labels[1].replace(tagRe, "").replace(/\s+/g, " ");
      var i = testDesc.indexOf(":");
      labels.push(testDesc.slice(0, i).trim(), testDesc.slice(i + 1).trim());
      const res = tagRe.exec(t.labels[1]);
      const tag = res !== null ? res.groups!["tag"] : "public";
      if (tag !== "hidden" && tag !== "public" && tag !== "ignore") {
        throw "Invalid tag";
      }
      return { ...t, labels, visibility: tag, type: "example" };
    } else if (t.labels[0].startsWith("Hidden.")) {
      if (t.labels[1] !== "hidden") {
        throw "Hidden tests must start with label 'hidden'";
      }
      const labels = [t.labels[0].replace("Hidden.", ""), ...t.labels.slice(2)];
      return { ...t, labels, visibility: "hidden", type: "test" };
    } else {
      return { ...t, type: "test", visibility: "public" };
    }
  }
  const parsed = inner(raw);
  if (parsed.type !== "example" && parsed.labels.length != 4) {
    throw `Invalid test label: ${parsed.labels}`;
  }
  return parsed;
}

interface TestResults {
  publicTests: TestData[];
  hiddenTests: TestData[];
}

export function loadTests(
  path: string,
  includeExamples: boolean = false
): TestResults {
  const content: string = fs.readFileSync(path, "utf-8");
  const lines = content.split("\n");
  const parsed = lines
    .filter((line) => line.length !== 0)
    .map((line) => JSON.parse(line));
  const runStart = parsed[0];
  const runEnd = parsed[parsed.length - 1];
  const testEvents: RawParsedTest[] = parsed.slice(1, -1);
  const tests = testEvents
    .map(parseTest)
    .filter((t) => t.type !== "example")
    .filter((t) => t.visibility !== "ignore");

  const hiddenTests = tests.filter((t) => t.visibility === "hidden");
  const publicTests = tests.filter((t) => t.visibility !== "hidden");
  return { publicTests, hiddenTests };
}

// function parseTest(t: RawParsedTest): TestData {
//   if (t.labels[0].includes("VerifyExamples")) {
//     let labels = t.labels[0].split(".").slice(0, -1);
//     const tagRe = /\{- (?<tag>\w+) -\}/g;
//     const res = tagRe.exec(t.labels[1]);
//     if (res !== null) {
//       const tag = res.groups["tag"];
//       labels.push(tag);
//     }
//     const testDesc = t.labels[1].replace(tagRe, "").replace(/\s+/g, " ");
//     let i = testDesc.indexOf(":");
//     labels.push(testDesc.slice(0, i).trim(), testDesc.slice(i + 1).trim());
//     return { ...t, labels };
//   } else if (t.labels[0].startsWith("Hidden.")) {
//     const labels = [t.labels[0].replace("Hidden.", ""), ...t.labels.slice(1)];
//     return { ...t, labels };
//   } else {
//     return { ...t, type: "test", visibility: "public" };
//   }
// }
