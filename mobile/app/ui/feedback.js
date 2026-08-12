const emptyFeedback = () => ({ error: null, notice: null });

const errorFeedback = (message, owner) => ({ error: { message, owner }, notice: null });

const noticeFeedback = (key, owner) => ({ error: null, notice: { key, owner } });

const feedbackForNavigation = (feedback, destination) => ({
  error: feedback.error?.owner === destination ? feedback.error : null,
  notice: feedback.notice?.owner === destination ? feedback.notice : null
});

module.exports = { emptyFeedback, errorFeedback, noticeFeedback, feedbackForNavigation };
