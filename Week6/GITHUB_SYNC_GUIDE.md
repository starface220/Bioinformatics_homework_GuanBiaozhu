# EMP GitHub Sync

The analysis is finished in the local EMP session. I cannot complete GitHub
Sync because it needs your student account, repository URL, and personal
access token.

## Use EMP GitHub Sync

1. Open `http://127.0.0.1:8080/`.
2. In the browser console, restore the session that contains the analysis:

   ```javascript
   localStorage.setItem("emp_session_id", "MYLQuB4Wvb429RvLHXEIuOvq");
   location.reload();
   ```

3. Check that the experiment is
   `microbiome_16s_week6` with 132 samples and 470 input features.
   The scientific interpretation, hypothesis, limitations, and AI-use
   declaration have already been saved to this session's teaching journal.
4. Open Export and log in with your student ID, name, and password.
5. Enter the repository URL and a fine-grained PAT with
   `Contents: Read and write` access to that repository.
6. Select the `16S 微生物组` track and `Week 6`.
7. Use a commit message such as `Week 6 EMP 16S analysis and hypothesis`.
8. Click `Sync to GitHub`.
9. A new run should appear under:

   ```text
   EMP2026/Week_06/<track>/weekly/runs/<timestamp>/
   ```

10. Open the new commit and check that
    `manifest.json`, `data/`, `results/`, and `teaching/` are present.

## If you upload manually

Upload the entire `submission` folder if the instructor accepts a normal
repository upload. Do not commit a password, student token, or GitHub PAT.
