<script setup>
import { computed } from 'vue';
import PageHero from '@/components/site/PageHero.vue';
import SectionTitle from '@/components/site/SectionTitle.vue';
import EventCard from '@/components/site/EventCard.vue';
import {
  useHeroImage,
  useTempleContent,
  useTempleOfferings,
  useTempleGatherings
} from '@/app/siteContent.js';
import { formatEventCard, statusLabel } from '@/utils/events.js';

const heroImage = useHeroImage('events');
const siteContent = useTempleContent();
const offeringsSource = useTempleOfferings();
const gatheringsSource = useTempleGatherings();

const defaultLocation = computed(
  () => siteContent.data?.contact?.addressZh || '本廟'
);

// What a visitor can still act on comes first: ongoing, then upcoming
// soonest-first, then finished most-recent-first. Plain chronological order
// buried a newly created event below events that had already ended.
//
// Ranked on timeline_status, which TempleEvent#timeline_status and
// TempleGathering#timeline_status compute server-side and the serializers
// already send. Re-deriving "ended" from dates here would let the ordering
// and the 已結束 badge disagree.
const TIMELINE_RANK = { ongoing: 0, upcoming: 1, past: 2 };
const rankOf = (item) => TIMELINE_RANK[item?.timeline_status] ?? 1;

const startTime = (item) => {
  const time = item?.starts_on ? new Date(item.starts_on).getTime() : null;
  return Number.isFinite(time) ? time : null;
};

const compareByStart = (a, b, newestFirst) => {
  const aTime = startTime(a);
  const bTime = startTime(b);
  if (aTime === null && bTime === null) return 0;
  if (aTime === null) return 1;
  if (bTime === null) return -1;
  return newestFirst ? bTime - aTime : aTime - bTime;
};

const sortByTimeline = (list = []) =>
  [...list].sort((a, b) => {
    const aRank = rankOf(a);
    const bRank = rankOf(b);
    if (aRank !== bRank) return aRank - bRank;
    return compareByStart(a, b, aRank === TIMELINE_RANK.past);
  });

// The hints say "進行中或即將開始" / "開放報名或即將舉辦", so they must not count
// events that have finished. formatEventCard drops timeline_status, so this
// counts the source records rather than the rendered cards.
const activeCount = (list = []) =>
  list.filter((item) => item?.timeline_status !== 'past').length;

const offerings = computed(() => {
  if (!offeringsSource.value?.length) return [];
  return sortByTimeline(offeringsSource.value).map((event) =>
    formatEventCard(event, {
      defaultLocation: defaultLocation.value
    })
  );
});

const gatherings = computed(() => {
  if (!gatheringsSource.value?.length) return [];
  return sortByTimeline(gatheringsSource.value).map((event) =>
    formatEventCard(event, {
      defaultLocation: defaultLocation.value
    })
  );
});

const hasOfferings = computed(() => offerings.value.length > 0);
const hasGatherings = computed(() => gatherings.value.length > 0);
const pageEmpty = computed(() => !hasOfferings.value && !hasGatherings.value);

const offeringsHint = computed(() => {
  const count = activeCount(offeringsSource.value);
  if (!count) {
    return statusLabel('upcoming');
  }
  return `共有 ${count} 檔法會供品進行中或即將開始。`;
});

const gatheringsHint = computed(() => {
  const count = activeCount(gatheringsSource.value);
  if (!count) {
    return '社群活動未開放報名，可直接洽詢服務台。';
  }
  return `共有 ${count} 場社群活動開放報名或即將舉辦。`;
});
</script>

<template>
  <div>
    <PageHero
      title="活動資訊"
      subtitle="線上瀏覽法會與社群聚會的時間、名額與地點，登入後即可填寫報名表。"
      :image-url="heroImage"
    />

    <section class="section">
      <div class="wrap">
        <SectionTitle
          title="法會供品"
          subtitle="依照開放時段整理的供奉項目，方便提前預約或了解流程。"
        />
        <div v-if="hasOfferings" class="grid">
          <EventCard v-for="event in offerings" :key="event.slug" :item="event" />
        </div>
        <div v-else class="empty">
          目前沒有開放的法會供品，歡迎追蹤最新公告或洽詢廟方。
        </div>

        <div class="hint">
          法會供品進度：{{ offeringsHint }}
        </div>
      </div>
    </section>

    <section class="section alt">
      <div class="wrap">
        <SectionTitle
          title="社群活動"
          subtitle="串連社區的聚會、講座或祈福活動，和法會供品一樣可在此報名。"
        />
        <div v-if="hasGatherings" class="grid">
          <EventCard v-for="event in gatherings" :key="event.slug" :item="event" />
        </div>
        <div v-else class="empty">
          目前沒有公布的社群活動，歡迎關注官方訊息或直接洽詢。
        </div>

        <div class="hint">
          社群活動進度：{{ gatheringsHint }}
        </div>
      </div>
    </section>

    <section v-if="pageEmpty" class="section">
      <div class="wrap">
        <div class="empty">
          目前尚未公布活動資訊，可直接電話洽詢或稍後回來查看。
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.empty {
  padding: var(--spacing-lg);
  text-align: center;
  opacity: 0.75;
  border-radius: var(--radius-lg);
  border: 1px dashed color-mix(in srgb, var(--border) 75%, transparent);
}

.hint {
  margin-top: var(--spacing-sm);
  opacity: 0.65;
  font-size: 13px;
  line-height: 1.6;
}
</style>
