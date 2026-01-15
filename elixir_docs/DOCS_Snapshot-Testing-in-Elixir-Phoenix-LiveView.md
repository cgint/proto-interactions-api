

# **Strategic Implementation of Snapshot Testing in a Legacy Elixir/Phoenix/LiveView Codebase**

## **1\. Executive Summary**

This report provides a comprehensive analysis and strategic roadmap for introducing automated testing into an existing Elixir/Phoenix/LiveView application that currently lacks a test suite. The absence of automated tests represents a significant technical risk, as it makes every code change, refactor, or feature addition a high-stakes activity with a strong potential for introducing unintended regressions. The common practice of "editing and praying" for the best outcome is both risky and stressful for a development team.1

The recommended solution is a pragmatic, phased approach centered on **characterization testing** via snapshot methodologies. This strategy is not a replacement for traditional unit or functional tests but serves as a rapid, low-effort method to establish a critical safety net. By "pinning" the existing, undocumented behavior of the system, snapshots provide a stable foundation from which to safely refactor and evolve the application.

The analysis focuses on two primary Elixir tools: heyya, which provides an opinionated and streamlined workflow for testing the UI layer of Phoenix components and LiveViews, and assert\_value\_elixir, a more general-purpose, interactive tool for asserting complex data structures and managing a wide range of application outputs. These tools are complementary and can be leveraged together to form a robust, multi-layered testing strategy.

The report outlines a three-phase roadmap: first, the rapid creation of a foundational safety net by adding characterization tests to high-risk areas; second, the integration of this new test suite into a daily development and continuous integration (CI) workflow; and finally, a deliberate process of using the confidence gained from these snapshots to refactor the codebase and gradually replace the characterization tests with more explicit, behavior-driven assertions where appropriate. This strategic implementation addresses the immediate need for regression prevention while laying the groundwork for a more mature and maintainable test suite in the long term.

## **2\. The Imperative for Characterization Testing in Legacy Systems**

The term "legacy code" is often misunderstood as simply code that is old. A more precise and actionable definition is code that lacks an automated test suite.2 This defining characteristic creates a challenging environment for a development team. Without automated tests, the team has no reliable mechanism to verify that a code change has not broken existing functionality. This absence of a safety net means that refactoring, a vital process for maintaining code health, becomes painful and risky.5

In such a situation, the "ideal approach" of reverse-engineering a full specification and writing a comprehensive unit test suite before making any changes is often prohibitively expensive and time-consuming.1 This can lead to a state of stasis where fear of breaking the system prevents any meaningful refactoring or improvement. The code remains in its "spaghetti" state, and the team's enthusiasm and productivity suffer.5

A more pragmatic and effective starting point is **characterization testing**, also known as "golden master" testing.1 This approach bypasses the need to understand and document the entire system's intended behavior upfront. Instead, it focuses on capturing and "pinning" the system's

*current* behavior, whether that behavior is right or wrong.8 The purpose is to establish a "ground truth" of how the application functions at a specific moment in time. This creates a stable and predictable foundation from which to work.

The process of implementing characterization tests directly addresses the psychological barrier that prevents teams from tackling technical debt. When a team has no automated tests, every change, no matter how small, is a step into the unknown. The introduction of a safety net fundamentally changes this dynamic. By running a suite of characterization tests, a developer can confidently proceed with a refactor or feature implementation, knowing that if a test fails, a change in the system's behavior has occurred.5 This allows for a deliberate decision to be made: either the change was intended and the snapshot should be updated, or it was an unintended regression that requires a fix. This shift from a state of fear and guesswork to one of deliberate action is the most significant and transformative outcome of this strategy.

## **3\. Understanding Snapshot Testing: A Foundation for Pragmatic Regression Prevention**

Snapshot testing is a powerful mechanism for implementing characterization tests, providing a broad safety net with minimal effort.8 The core concept is simple: a snapshot test renders a component or executes a function, captures a serializable representation of its output (e.g., HTML, JSON, or a data structure), and saves it as a "golden master" file.7 On subsequent test runs, the new output is compared against the stored snapshot. Any differences cause the test to fail.

### **Advantages of Snapshot Testing**

The popularity of snapshot testing stems from several key advantages:

* **Low Effort and Rapid Coverage:** Snapshot tests are exceptionally easy and convenient to create.5 They require very little setup code, allowing a development team to quickly add a wide range of regression checks. This ease of creation is particularly valuable when faced with a large, untested codebase.  
* **Broad Scope:** They function as a "shotgun aimed at state verification," capturing a wide range of data points at once.8 This is especially useful for complex UI components or for functions that produce long, non-meaningful outputs (e.g., a minified HTML string or the output of a code beautifier).5  
* **Effective Regression Detection:** Snapshot tests are a "fantastic tool for identifying unexpected interface changes".10 They can catch a variety of regressions in appearance, layout, or data format that a traditional, narrowly-focused test might miss.17 A test failure immediately flags that the output has changed, prompting a review of the cause.

### **Disadvantages and the Snapshot Paradox**

Despite these benefits, snapshot testing is not a panacea. The very simplicity that makes them easy to create is also the source of their primary weaknesses. This is a fundamental contradiction at the heart of the methodology:

* **Fragility and Noise:** Snapshot tests are tightly coupled to the application's output, making them fragile.7 A minor, intended change in a low-level component can cause a cascade of failures in higher-level components that use it.5 This can create "noisy" test failures that are difficult and overwhelming to maintain.9  
* **Lack of Explicit Assertion:** A snapshot test simply asserts that the output has not changed; it does not assert that the output is *correct*.7 This means that the test provides no context for  
  *why* something changed, forcing the developer to act as a detective to determine if the change was a bug or an intended refactor.5  
* **A False Sense of Confidence:** The low-effort nature of snapshots makes it easy to achieve a high code coverage metric. However, this metric can be misleading. A test suite composed solely of snapshots provides a "false sense of security" because it checks for stability, not for correctness or behavior.5

The ease of generating snapshots can lead to a dangerous habit: developers, faced with a large list of failing snapshots, may be tempted to simply re-generate and commit them without a thorough review of the changes.5 This undermines the entire purpose of the test suite, effectively making the tests useless.

### **Best Practices for a Sustainable Suite**

To mitigate these risks and create a sustainable snapshot suite, a team must adopt strict practices from the outset:

1. **Treat Snapshots as Code:** Snapshots should be committed to version control and subjected to the same rigorous peer review process as the application code itself.10 The goal is to enforce a deliberate review of every snapshot change and to prevent the habit of simply regenerating tests without understanding the underlying cause of failure.  
2. **Ensure Determinism:** A snapshot test is only useful if it produces the exact same output on every run. Non-deterministic data, such as timestamps, random IDs, or the order of items in a non-ordered data structure, will cause tests to fail constantly and render the suite useless.10 It is the developer's responsibility to handle these unpredictable values through canonicalization or mocking.  
3. **Use Descriptive Names:** Every snapshot test should have a clear and descriptive name that explains the expected output. A name such as "should render null" is far more useful to a reviewer or a future developer than a generic name like "should handle some test case".10

## **4\. The Elixir Ecosystem's Tools for Snapshotting**

The Elixir ecosystem offers powerful and complementary tools for implementing snapshot testing. While the concept originated in the JavaScript world with tools like Jest 10, these Elixir libraries have been designed to integrate seamlessly with the language's strengths and the Phoenix framework's conventions.

### **heyya: A Focused Approach for Phoenix Components and LiveViews**

heyya is an opinionated utility specifically designed to simplify the testing of Phoenix components and LiveViews.20 It provides a high-level, streamlined workflow for snapshotting the UI layer of a Phoenix application.

* **Functionality:** heyya provides two primary test cases: Heyya.SnapshotCase for testing stateless function components and Heyya.LiveCase for testing full LiveViews.21 The  
  component\_snapshot\_test macro makes it easy to capture the rendered output of a component and compare it against a snapshot.15  
* **Key Features:** heyya integrates directly with ExUnit and the Phoenix.LiveViewTest library, leveraging existing test conventions.22 It supports a specific environment variable,  
  HEYYA\_OVERRIDE=true, to signal that snapshots should be updated, a common practice borrowed from other ecosystems.15 A particularly valuable feature is the ability to use a CSS selector to capture only a specific, relevant part of a LiveView's HTML output, which helps mitigate the fragility of large snapshots by focusing on a smaller surface area.21

### **assert\_value\_elixir: The General-Purpose Assertion Helper**

assert\_value\_elixir is a more general-purpose tool that extends ExUnit to automatically generate and manage expected values for a wide range of assertions.24 It is not tied to the Phoenix framework and can be used to test any part of an Elixir application.

* **Functionality:** The library operates interactively. When a test with an assert\_value assertion is run for the first time, it generates the expected value and prompts the user to accept it. The tool then automatically updates the source code with the new value. If a test fails in the future, it displays a diff and prompts the user to either accept the new value or fix the code.24  
* **Key Features:** It can handle long values, such as complex data structures or large strings, by storing them in separate files rather than cluttering the source code.24 This also prevents repository bloat. Crucially,  
  assert\_value\_elixir provides a robust mechanism for **canonicalization**, which allows a serialization function to be passed to the assertion. This function can sanitize non-deterministic data (e.g., timestamps, IDs, or the order of a map) to ensure that the snapshot remains stable and predictable.24 This canonicalization capability is vital for creating robust snapshot tests. It can also be configured to run non-interactively, which is essential for a CI environment where manual user input is not possible.24

### **Comparative and Synergistic Application**

These two tools are not competitors but are designed to address different testing concerns within a Phoenix application. Their designs reflect the layered architecture of a modern web application, where UI, business logic, and data transformations exist in different layers.

| Feature | heyya | assert\_value\_elixir |
| :---- | :---- | :---- |
| **Primary Use Case** | Phoenix Components & LiveViews (UI Layer) | General-purpose data assertion in any Elixir module |
| **Interactive Mode** | No, relies on HEYYA\_OVERRIDE environment variable | Yes, prompts user to accept/reject changes in the terminal |
| **Assertion Type** | Opinionated macros (component\_snapshot\_test) | assert\_value(value) macro |
| **Snapshot Storage** | Stores snapshots in an in-file \_\_snapshots\_\_ directory | Can store snapshots in external files or inline in the source code 24 |
| **Key Integration** | Phoenix.LiveViewTest, Phoenix.Component | ExUnit |
| **Non-determinism** | Handled by canonicalizing data within the test before calling the assertion function. | Built-in canonicalization function to transform values before assertion 24 |
| **Target Audience** | Front-end developers, UI/UX teams | Any developer writing tests in Elixir |

This distinction suggests a synergistic approach. heyya is the ideal, high-level, and opinionated choice for the UI/UX layer. It is built to understand and abstract the complexities of LiveView rendering and component testing, making it a streamlined solution for visual and structural regressions in the user interface. In contrast, assert\_value\_elixir is a flexible, lower-level utility that can be used as a Swiss Army knife across the entire codebase. It is the appropriate tool for asserting complex data transformations, API payloads, or other outputs that are not part of the UI. By leveraging the specialized capabilities of heyya for UI concerns and the general-purpose power of assert\_value\_elixir for other data assertions, a development team can create a robust and comprehensive test suite that is well-suited to the different layers of their application.

## **5\. A Strategic Implementation Roadmap for an Untested Codebase**

The process of adding a test suite to a legacy codebase can be daunting. The following three-phase roadmap provides a strategic, incremental path to confidently tackling this technical debt.

### **Phase 1: Gaining a Safety Net with Characterization Tests**

The initial goal is not to achieve 100% test coverage but to establish a "pinning test" for every area of the codebase that a team intends to refactor or change.6 This provides an immediate, high-value safety net.

* **Identify High-Value Areas:** A team should begin by analyzing version control history to identify the most frequently changed or critical parts of the application.6 These are the areas where the risk of regression is highest and where the initial investment in testing will yield the greatest return.  
* **Pinning Core Behaviors:** For stateless UI components, heyya's component\_snapshot\_test provides a straightforward way to capture the rendered output and "pin" its current structure and appearance.15 For full-page LiveViews, a more targeted approach is recommended. By using a specific CSS selector, the  
  Heyya.LiveCase.assert\_matches\_snapshot function can capture only the critical parts of the page, avoiding the fragility of a full-page snapshot.21 For complex backend logic or data transformations,  
  assert\_value\_elixir is the tool of choice. The output of a function can be piped into an assert\_value assertion, with the "golden master" stored in a separate file for readability.24 This captures the current behavior of the business logic.  
* **The "Pin and Refactor" Loop:** This phase is about creating momentum. The act of adding the snapshot tests turns a daunting task into a manageable process. A developer can now perform a small refactor or add a new feature, knowing that a failing test will immediately signal that the behavior has changed. This allows for a conscious decision to be made: either the change was intended (and the snapshot should be updated) or it was a bug that needs to be fixed. This process breaks the cycle of fear and stasis, enabling a team to work more productively and confidently.7

### **Phase 2: Integrating Snapshot Tests into the Development Workflow**

A test suite is only valuable if it is an integrated part of the daily development process. The following steps are critical for ensuring the longevity and utility of the snapshots.

* **Automate with CI/CD:** A continuous integration pipeline, such as GitHub Actions, should be configured to run the entire test suite on every pull request.3 For snapshot tests, the non-interactive mode of tools like  
  assert\_value\_elixir is essential, as the CI environment cannot prompt a user for input.24  
* **Mandate Code Review of Diffs:** This is the most crucial step in the entire process. The pull request review is the moment of truth for a snapshot test. A reviewer must manually check the snapshot diffs to ensure that any changes are intentional and correct.10 This practice prevents the dangerous habit of regenerating snapshots without a thorough review, thereby preserving the value of the test suite.

### **Phase 3: Evolving the Test Suite Beyond Snapshots**

Snapshots are a means to an end, not the final destination. Once a codebase is "pinned" and a team has confidence in their ability to detect regressions, the focus can shift to building a more robust and explicit test suite.

* **The Safety Net in Action:** With the snapshots in place, the team can begin to safely refactor code that was previously untouchable. When a test fails, the snapshot diff provides a precise and immediate warning that the output has changed. This is a clear indicator that the developer must review the change.7  
* **Gradual Replacement:** As a section of code is refactored, its behavior becomes clearer and more deliberate. At this point, it becomes easier to write precise, high-value, and behavior-driven unit and integration tests.3 For example, a snapshot test that captured the entire output of a function might be replaced with a series of smaller, more targeted tests that assert on specific inputs and outputs. Once these more explicit tests are in place, the broad snapshot test for that area can be deprecated or replaced with a more focused one. This iterative process allows a team to systematically tackle technical debt and move from a fragile, implicit test suite to a more robust and maintainable one.

## **6\. Addressing Common Challenges: Non-Deterministic Data and Snapshot Maintenance**

The biggest hurdle in maintaining a healthy snapshot test suite is handling non-deterministic data. A snapshot test that fails on every run because of a changing timestamp or random ID is worthless and will be a source of constant noise and developer frustration.10

### **Strategies for Canonicalization**

The fundamental principle for addressing this problem is to make the testable output deterministic.

* **Fix the Code, Not the Test:** The first and most effective strategy is to identify and address the source of non-determinism in the application code itself. For example, if a test is failing because the order of database query results is not consistent, the architectural solution is not to simply mock the data but to add an ORDER BY clause to the query.19 This not only fixes the test but also improves the underlying quality and predictability of the application code. This practice demonstrates that a well-designed test suite can serve as an indicator of architectural quality.  
* **Mocking:** If the non-deterministic behavior cannot be changed in the application code itself, a developer can mock or override the functions that produce the unpredictable data. For instance, Date.now() can be mocked to return a consistent, predictable value on every test run.10  
* **Canonicalization Functions:** Tools like assert\_value\_elixir provide a powerful way to handle this problem directly within the test. A developer can write a function to sanitize the non-deterministic parts of the output before it is sent to the assertion. For example, a canonicalization function could replace a UUID or timestamp with a static placeholder, ensuring that the test only checks for the stable parts of the output.12

### **Managing Large and Fragile Snapshot Suites**

The ease of creating snapshots can lead to a bloated and fragile test suite. To avoid this, a strategic approach to maintenance is required.

* **Granular Snapshots:** The most effective way to combat fragility is to limit the scope of the snapshot. Instead of capturing the entire output of a LiveView, a developer can use a CSS selector to focus on a small, specific, and stable part of the page.21 This reduces the surface area for change and ensures that a refactor in one area does not cause unrelated test failures in another.  
* **File-Based Storage:** For very long or complex outputs, such as large JSON payloads or extensive HTML, storing the snapshot inline in the source code can make the code unreadable and difficult to manage. Tools like assert\_value\_elixir provide the option to store these long values in separate files, which are still committed to version control but do not clutter the test file itself.24

## **7\. Conclusion & Recommendations**

Snapshot testing is a powerful, pragmatic, and low-effort tool for a specific purpose: providing a crucial regression safety net for a legacy codebase. It is not a replacement for traditional, behavior-driven testing but a vital first step that enables a development team to confidently tackle technical debt and move forward.

The analysis of the Elixir ecosystem reveals that heyya and assert\_value\_elixir offer a robust and complementary toolkit for this task. heyya provides an opinionated, streamlined experience for the UI layer, while assert\_value\_elixir is a flexible, general-purpose helper for a wide range of data assertions.

Based on this analysis, the following actionable recommendations are provided:

1. **Start with a Pilot:** The team should begin with a small, high-value component or module to implement a pilot snapshot test suite. This provides a low-risk environment to get the team comfortable with the workflow and to establish team-wide best practices for snapshot creation and maintenance.  
2. **Use the Right Tool for the Job:** Leverage heyya for UI-focused snapshots of Phoenix components and LiveViews. For asserting the output of complex backend logic, API clients, or data transformations, use the more flexible and powerful canonicalization features of assert\_value\_elixir.  
3. **Establish a Review Ritual:** Integrate snapshot diff reviews into the daily pull request process. Mandating that a reviewer manually inspect any snapshot changes is the single most important practice for preventing the "update and commit" problem and ensuring the long-term value of the test suite.  
4. **Evolve, Don't Stop:** Recognize that snapshots are a temporary tool on the path to a more mature test suite. Use the confidence gained from the snapshot suite as a catalyst to begin writing more explicit, behavior-driven tests for critical business logic. As a module's behavior becomes better understood and tested, the broad snapshot test can be replaced with a more focused, high-value test, resulting in a cleaner and more maintainable test suite over time.

#### **Works cited**

1. TDD and legacy code: creating a snapshot with approval tests \- Medium, accessed on August 30, 2025, [https://medium.com/ns-techblog/tdd-and-legacy-code-creating-a-snapshot-with-approval-tests-252327b6c72e](https://medium.com/ns-techblog/tdd-and-legacy-code-creating-a-snapshot-with-approval-tests-252327b6c72e)  
2. Characterization Tests With Snapshot Testing \- NimblePros Blog, accessed on August 30, 2025, [https://blog.nimblepros.com/blogs/characterization-tests-with-snapshot-testing/](https://blog.nimblepros.com/blogs/characterization-tests-with-snapshot-testing/)  
3. How to regain control in a legacy codebase | by Adrien Joly | shodo.io \- Medium, accessed on August 30, 2025, [https://medium.com/shodo-io/how-to-regain-control-in-a-legacy-codebase-ee1b874e351b](https://medium.com/shodo-io/how-to-regain-control-in-a-legacy-codebase-ee1b874e351b)  
4. How to add tests on existing code when you have short deadlines : r/programming \- Reddit, accessed on August 30, 2025, [https://www.reddit.com/r/programming/comments/eunf24/how\_to\_add\_tests\_on\_existing\_code\_when\_you\_have/](https://www.reddit.com/r/programming/comments/eunf24/how_to_add_tests_on_existing_code_when_you_have/)  
5. Jest snapshots: useless or harmful? \- Brains & Beards, accessed on August 30, 2025, [https://brainsandbeards.com/blog/snapshot-testing/](https://brainsandbeards.com/blog/snapshot-testing/)  
6. Writing Tests for Existing Code \- Software Engineering Stack Exchange, accessed on August 30, 2025, [https://softwareengineering.stackexchange.com/questions/207401/writing-tests-for-existing-code](https://softwareengineering.stackexchange.com/questions/207401/writing-tests-for-existing-code)  
7. Snapshot Testing: Benefits and Drawbacks \- SitePen, accessed on August 30, 2025, [https://www.sitepen.com/blog/snapshot-testing-benefits-and-drawbacks](https://www.sitepen.com/blog/snapshot-testing-benefits-and-drawbacks)  
8. Snapshot Testing in JavaScript & .NET | by Matt Eland \- Medium, accessed on August 30, 2025, [https://matteland.medium.com/snapshot-testing-in-javascript-net-1dc259f1c7a](https://matteland.medium.com/snapshot-testing-in-javascript-net-1dc259f1c7a)  
9. storybook.js.org, accessed on August 30, 2025, [https://storybook.js.org/docs/writing-tests/snapshot-testing\#:\~:text=Snapshot%20testing%20is%20simply%20rendering,snapshot%20contains%20too%20much%20information.](https://storybook.js.org/docs/writing-tests/snapshot-testing#:~:text=Snapshot%20testing%20is%20simply%20rendering,snapshot%20contains%20too%20much%20information.)  
10. Snapshot Testing \- Jest, accessed on August 30, 2025, [https://jestjs.io/docs/snapshot-testing](https://jestjs.io/docs/snapshot-testing)  
11. Snapshot testing React applications with Jest \- CircleCI, accessed on August 30, 2025, [https://circleci.com/blog/snapshot-testing-with-jest/](https://circleci.com/blog/snapshot-testing-with-jest/)  
12. Snapshot testing \- Deno Docs, accessed on August 30, 2025, [https://docs.deno.com/examples/snapshot\_tutorial/](https://docs.deno.com/examples/snapshot_tutorial/)  
13. Exploring Snapshot Testing in Jest: Pros and Cons | Fresh Caffeine, accessed on August 30, 2025, [https://www.fresh-caffeine.com/blog/2024/snapshot-tests-in-jest/](https://www.fresh-caffeine.com/blog/2024/snapshot-tests-in-jest/)  
14. Snapshot testing in practice: Benefits and drawbacks \- ResearchGate, accessed on August 30, 2025, [https://www.researchgate.net/publication/372190746\_Snapshot\_testing\_in\_practice\_Benefits\_and\_drawbacks](https://www.researchgate.net/publication/372190746_Snapshot_testing_in_practice_Benefits_and_drawbacks)  
15. Heyya.SnapshotCase — heyya v2.0.0 \- HexDocs, accessed on August 30, 2025, [https://hexdocs.pm/heyya/Heyya.SnapshotCase.html](https://hexdocs.pm/heyya/Heyya.SnapshotCase.html)  
16. Snapshy v0.4.0 \- HexDocs, accessed on August 30, 2025, [https://hexdocs.pm/snapshy/index.html](https://hexdocs.pm/snapshy/index.html)  
17. Visual testing & review for web user interfaces • Chromatic, accessed on August 30, 2025, [https://www.chromatic.com/](https://www.chromatic.com/)  
18. Do you do Snapshot Testing? \- DEV Community, accessed on August 30, 2025, [https://dev.to/dvddpl/do-you-do-snapshot-testing-35g5](https://dev.to/dvddpl/do-you-do-snapshot-testing-35g5)  
19. Testing non-deterministic code \- HitchDev, accessed on August 30, 2025, [https://hitchdev.com/hitchstory/approach/testing-nondeterministic-code/](https://hitchdev.com/hitchstory/approach/testing-nondeterministic-code/)  
20. batteries-included/heyya: Heyya the snapshot testing utility ... \- GitHub, accessed on August 30, 2025, [https://github.com/batteries-included/heyya](https://github.com/batteries-included/heyya)  
21. heyya v2.0.1 \- HexDocs, accessed on August 30, 2025, [https://hexdocs.pm/heyya/](https://hexdocs.pm/heyya/)  
22. lib/heyya.ex \- Hex Preview, accessed on August 30, 2025, [https://preview.hex.pm/preview/heyya/0.1.2/show/lib/heyya.ex](https://preview.hex.pm/preview/heyya/0.1.2/show/lib/heyya.ex)  
23. Heyya v1.0.0 Elixir and Phoenix LiveView Snapshot Testing Library \- Reddit, accessed on August 30, 2025, [https://www.reddit.com/r/elixir/comments/1efzs3r/heyya\_v100\_elixir\_and\_phoenix\_liveview\_snapshot/](https://www.reddit.com/r/elixir/comments/1efzs3r/heyya_v100_elixir_and_phoenix_liveview_snapshot/)  
24. assert-value/assert\_value\_elixir: ExUnit's assert on steroids ... \- GitHub, accessed on August 30, 2025, [https://github.com/assert-value/assert\_value\_elixir](https://github.com/assert-value/assert_value_elixir)