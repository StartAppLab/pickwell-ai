export interface Testimonial {
  name: string;
  title: string;
  content: string;
  image: string | undefined;
}

export const testimonialData = {
  testimonials: [
    {
      name: 'Sarah Chen',
      title: 'Graduate Student',
      content:
        'StartAppNotes has completely changed how I take lecture notes. The folder organization keeps all my classes separate, and the search feature helps me find anything instantly. I love that it syncs across my phone and tablet so I can review anywhere.',
      image: '',
    },
    {
      name: 'Marcus Rodriguez',
      title: 'Project Manager',
      content:
        'I use StartAppNotes for all my meeting notes and project planning. The checklists are perfect for tracking action items, and cloud sync means my notes are always available. It is simple, fast, and exactly what I needed.',
      image: '',
    },
    {
      name: 'Emma Thompson',
      title: 'Writer',
      content:
        'As a writer, I need to capture ideas whenever inspiration strikes. StartAppNotes opens instantly, and the clean interface helps me focus on writing. The markdown support is brilliant for formatting my drafts.',
      image: '',
    },
    {
      name: 'David Park',
      title: 'Entrepreneur',
      content:
        'StartAppNotes replaced four different apps for me. Meeting notes, personal journal, shopping lists, and project ideas are all in one place now. The tag system makes it easy to organize everything.',
      image: '',
    },
    {
      name: 'Lisa Martinez',
      title: 'Teacher',
      content:
        'I use StartAppNotes to plan my lessons and keep track of student progress. It works offline which is perfect for my classroom, and the sync feature means I can access my notes from home too.',
      image: '',
    },
    {
      name: 'James Wilson',
      title: 'Software Developer',
      content:
        'Finally, a notes app that does not get in the way. StartAppNotes is minimal but powerful. I jot down code snippets, debugging notes, and ideas throughout the day. Dark mode is easy on my eyes during late night coding.',
      image: '',
    },
  ],
};
